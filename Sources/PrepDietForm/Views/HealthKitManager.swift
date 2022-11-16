import HealthKit
import PrepDataTypes

extension EnergyUnit {
    var healthKitUnit: HKUnit {
        switch self {
        case .kcal:
            return .kilocalorie()
        case .kJ:
            return .jouleUnit(with: .kilo)
        }
    }
}

class HealthKitManager: ObservableObject {

    static let shared = HealthKitManager()
    
    let store: HKHealthStore = HKHealthStore()
    
    func requestPermission(for type: HKQuantityTypeIdentifier) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitManagerError.healthKitNotAvailable
        }
        
        let quantityTypes: [HKQuantityTypeIdentifier] = [
            type,
        ]
        
        var readTypes: [HKObjectType] = []
        readTypes.append(contentsOf: quantityTypes.compactMap { HKQuantityType($0) })

        do {
            try await store.requestAuthorization(toShare: Set(), read: Set(readTypes))
        } catch {
            throw HealthKitManagerError.permissionsError(error)
        }
    }
    
    func requestPermission() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        let quantityTypes: [HKQuantityTypeIdentifier] = [
            .activeEnergyBurned,
            .basalEnergyBurned,
            .bodyMass,
            .bodyFatPercentage,
            .height,
        ]
        
        let characteristicTypes: [HKCharacteristicTypeIdentifier] = [
            .biologicalSex,
            .dateOfBirth,
            .wheelchairUse, //TODO: Set this in our backend under the User's characteristics and use it in TDEE calculation
            .activityMoveMode //TODO: Remove this after checking it out
        ]

        var readTypes: [HKObjectType] = []
        readTypes.append(contentsOf: quantityTypes.compactMap { HKQuantityType($0) })
        readTypes.append(contentsOf: characteristicTypes.compactMap { HKCharacteristicType($0) } )

        do {
            try await store.requestAuthorization(toShare: Set(), read: Set(readTypes))
            return true
        } catch {
            print("Error requesting authorization: \(error)")
            return false
        }

//        dispatch_async(dispatch_get_main_queue(), self.startObservingHeightChanges)

    }

    func startObservingHeightChanges() {
//
//       let sampleType =  HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
//
//       var query: HKObserverQuery = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: self.heightChangedHandler)
//
//       healthKitStore.executeQuery(query)
//       healthKitStore.enableBackgroundDeliveryForType(sampleType, frequency: .Immediate, withCompletion: {(succeeded: Bool, error: NSError!) in
//
//           if succeeded{
//               println("Enabled background delivery of weight changes")
//           } else {
//               if let theError = error{
//                   print("Failed to enable background delivery of weight changes. ")
//                   println("Error = \(theError)")
//               }
//           }
//       })
   }

    func heightChangedHandler(query: HKObserverQuery!, completionHandler: HKObserverQueryCompletionHandler!, error: NSError!) {
//
//       // Here you need to call a function to query the height change
//
//       // Send the notification to the user
//       var notification = UILocalNotification()
//       notification.alertBody = "Changed height in Health App"
//       notification.alertAction = "open"
//       notification.soundName = UILocalNotificationDefaultSoundName
//
//       UIApplication.sharedApplication().scheduleLocalNotification(notification)
//
//       completionHandler()
   }

//   func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//
//       application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil))
//
//       self.authorizeHealthKit { (authorized,  error) -> Void in
//           if authorized {
//               println("HealthKit authorization received.")
//           }
//           else {
//               println("HealthKit authorization denied!")
//               if error != nil {
//                   println("\(error)")
//               }
//           }
//       }
//
//       return true
//   }
}

extension HealthKitManager {
    func getLatestWeight() async -> (Double, Date)? {
        await getLatestQuantity(for: .bodyMass, using: .gramUnit(with: .kilo))
    }

    func getLatestHeight() async -> (Double, Date)? {
        await getLatestQuantity(for: .height, using: .meterUnit(with: .centi))
    }

    func getLatestQuantity(for typeIdentifier: HKQuantityTypeIdentifier, using unit: HKUnit) async -> (Double, Date)? {
        do {
            let sample = try await getLatestQuantitySample(for: typeIdentifier)
            let quantity = sample.quantity.doubleValue(for: unit)
            let date = sample.startDate
            return (quantity, date)
        } catch {
            print("Error getting quantity")
            return nil
        }
    }
    
    var biologicalSex: HKBiologicalSex {
        do {
            return try store.biologicalSex().biologicalSex
        } catch {
            print("Error getting biological sex")
            return .notSet
        }
    }

    var dateOfBirth: Date? {
        do {
            return try store.dateOfBirthComponents().date
        } catch {
            print("Error getting age")
            return nil
        }
    }
    
    func averageSumOfRestingEnergy(using energyUnit: EnergyUnit, overPast value: Int, interval: HealthAppInterval) async throws -> Double? {
        try await averageSum(
            for: .basalEnergyBurned,
            using: energyUnit.healthKitUnit,
            overPast: value,
            interval: interval
        )
    }

    func averageSumOfActiveEnergy(sing energyUnit: EnergyUnit, overPast value: Int, interval: HealthAppInterval) async throws -> Double? {
        try await averageSum(
            for: .activeEnergyBurned,
            using: energyUnit.healthKitUnit,
            overPast: value,
            interval: interval
        )
    }

    func averageSum(for typeIdentifier: HKQuantityTypeIdentifier, using unit: HKUnit, overPast value: Int, interval: HealthAppInterval) async throws -> Double? {
        let sumQuantities = try await sumQuantities(for: typeIdentifier, overPast: value, interval: interval)
        for (date, sumQuantity) in sumQuantities.sorted(by: { $0.key > $1.key }) {
            let value = sumQuantity.doubleValue(for: unit)
            print("\(value) on \(date.calendarDayString)")
        }
        //TODO: now sum up the values and return the total
        return nil
    }

    func sumQuantities(for typeIdentifier: HKQuantityTypeIdentifier, overPast value: Int, interval: HealthAppInterval) async throws -> [Date: HKQuantity] {
        guard let dateRange = interval.dateRangeOfPast(value) else {
            throw HealthKitManagerError.dateCreationError
        }
        
        let collection = try await statisticsCollection(for: typeIdentifier, overPast: value, interval: interval)
        var sumQuantities: [Date: HKQuantity] = [:]
        for day in dateRange.days {
            guard let statistics = collection.statistics(for: day) else {
                throw HealthKitManagerError.couldNotGetStatistics
            }
            guard let sumQuantity = statistics.sumQuantity() else {
                throw HealthKitManagerError.couldNotGetSumQuantity
            }
            sumQuantities[day] = sumQuantity
        }
        return sumQuantities
    }
    
    private func statisticsCollection(
        for typeIdentifier: HKQuantityTypeIdentifier,
        overPast value: Int,
        interval: HealthAppInterval
    ) async throws -> HKStatisticsCollection {

        guard let range = interval.dateRangeOfPast(value) else {
            throw HealthKitManagerError.dateCreationError
        }

        /// Always get samples up to the start of tomorrow, so that we get all of today's results too in case we need it
        let endDate = Date().startOfDay.moveDayBy(1)
        
        let datePredicate = HKQuery.predicateForSamples(withStart: range.lowerBound, end: endDate)

        print("Creating datePredicate with: \(range.lowerBound.calendarDayString) to \(endDate.calendarDayString)")
        
        /// Create the query descriptor.
        let type = HKSampleType.quantityType(forIdentifier: typeIdentifier)!
        let samplesPredicate = HKSamplePredicate.quantitySample(type: type, predicate: datePredicate)

        /// We want the sum of each day
        let everyDay = DateComponents(day: 1)
        
        let asyncQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplesPredicate,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: everyDay
        )
        return try await asyncQuery.result(for: store)
    }

    private func getLatestQuantitySample(for typeIdentifier: HKQuantityTypeIdentifier) async throws -> HKQuantitySample {
        let type = HKSampleType.quantityType(forIdentifier: typeIdentifier)!
        let predicates: [HKSamplePredicate<HKSample>] = [HKSamplePredicate.sample(type: type)]
        let sortDescriptors: [SortDescriptor<HKSample>] = [SortDescriptor(\.startDate, order: .reverse)]
        let limit = 1
        let asyncQuery = HKSampleQueryDescriptor(predicates: predicates, sortDescriptors: sortDescriptors, limit: limit)
        let results = try await asyncQuery.result(for: store)
        guard let sample = results.first as? HKQuantitySample else {
            throw HealthKitManagerError.couldNotGetSample
        }
        return sample
    }
    
    //MARK: - Legacy to be removed
    
    private func getSumQuantity(for typeIdentifier: HKQuantityTypeIdentifier) async throws -> HKQuantity {
        let statisticsCollection = try await statisticsCollection(for: typeIdentifier, overPast: 1, interval: .day)
        guard let statistics = statisticsCollection.statistics(for: Date().moveDayBy(-1)) else {
            throw HealthKitManagerError.couldNotGetSample
        }
        guard let sumQuantity = statistics.sumQuantity() else {
            throw HealthKitManagerError.couldNotGetSample
        }
        return sumQuantity
    }
    
    func getLatestRestingEnergy() async -> Double? {
        //TODO: Make this take in a unit
        await getSumQuantity(for: .basalEnergyBurned, using: .kilocalorie())
    }

    func getLatestActiveEnergy() async -> Double? {
        //TODO: Make this take in a unit
        await getSumQuantity(for: .activeEnergyBurned, using: .kilocalorie())
    }


    func getSumQuantity(for typeIdentifier: HKQuantityTypeIdentifier, using unit: HKUnit) async -> Double? {
        do {
            let sumQuantity = try await getSumQuantity(for: typeIdentifier)
            return sumQuantity.doubleValue(for: unit)
        } catch {
            print("Error getting sum quantity")
            return nil
        }
    }

    
}

enum HealthKitManagerError: Error {
    case healthKitNotAvailable
    case permissionsError(Error)
    case couldNotGetSample
    case couldNotGetStatistics
    case couldNotGetSumQuantity
    case dateCreationError
}
