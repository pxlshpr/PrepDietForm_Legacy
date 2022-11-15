import HealthKit

class HealthKitManager: ObservableObject {

    static let shared = HealthKitManager()
    
    let store: HKHealthStore = HKHealthStore()
    
    
    func requestPermission(for type: HKQuantityTypeIdentifier) async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        let quantityTypes: [HKQuantityTypeIdentifier] = [
            .basalEnergyBurned,
        ]
        
        var readTypes: [HKObjectType] = []
        readTypes.append(contentsOf: quantityTypes.compactMap { HKQuantityType($0) })

        do {
            try await store.requestAuthorization(toShare: Set(), read: Set(readTypes))
            return true
        } catch {
            print("Error requesting authorization: \(error)")
            return false
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

    func getLatestRestingEnergy() async -> Double? {
        await getSumQuantity(for: .basalEnergyBurned, using: .kilocalorie())
    }

    func getLatestActiveEnergy() async -> Double? {
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

    private func getSumQuantity(for typeIdentifier: HKQuantityTypeIdentifier) async throws -> HKQuantity {
        
//        let now = Date()
//        let startDate = Date()
////        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: now)!
//
        // Create a predicate for this week's samples.
        let calendar = Calendar(identifier: .gregorian)
//        let today = calendar.startOfDay(for: Date())
        let today = calendar.startOfDay(for: Date())

        guard let endDate = calendar.date(byAdding: .day, value: 1, to: today) else {
            fatalError("*** Unable to calculate the end time ***")
        }

        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
            fatalError("*** Unable to calculate the start time ***")
        }

        let thisWeek = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        // Create the query descriptor.
//        let stepType = HKQuantityType(.stepCount)
        let type = HKSampleType.quantityType(forIdentifier: typeIdentifier)!
        let samplesThisWeek = HKSamplePredicate.quantitySample(type: type, predicate: thisWeek)

        let everyDay = DateComponents(day: 1)
        
//        let thisWeek = HKQuery.predicateForSamples(withStart: startDate, end: startDate)
//        let predicate = HKSamplePredicate.quantitySample(type: type, predicate: thisWeek)

        let asyncQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplesThisWeek,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: everyDay
        )
        let results = try await asyncQuery.result(for: store)
        guard let statistics = results.statistics(for: Date().moveDayBy(-1)) else {
            throw HealthKitManagerError.couldNotGetSample
        }
        guard let sumQuantity = statistics.sumQuantity() else {
            throw HealthKitManagerError.couldNotGetSample
        }
        return sumQuantity
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
    
}

enum HealthKitManagerError: Error {
    case couldNotGetSample
}
