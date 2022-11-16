import SwiftUI
import PrepDataTypes
import SwiftHaptics

extension TDEEForm.ViewModel {
    var restingEnergyFormatted: String {
        guard let restingEnergy else {
            return ""
        }
        return restingEnergy.formattedEnergy
    }

    var lbmFormatted: String {
        lbm?.cleanAmount ?? ""
    }

    var lbmFormattedWithUnit: String {
        guard let lbm else { return "" }
        return lbm.cleanAmount + " " + userWeightUnit.shortDescription
    }

    var weightFormatted: String {
        weight?.cleanAmount ?? ""
    }

    var weightFormattedWithUnit: String {
        guard let weight else { return "" }
        return weight.cleanAmount + " " + userWeightUnit.shortDescription
    }

    var notSetup: Bool {
        true
    }
    
    var detents: Set<PresentationDetent> {
        notSetup ? [.height(270), .large] : [.medium, .large]
    }
    
    var maintenanceEnergy: Double? {
        nil
    }
    
    var hasRestingEnergy: Bool {
        restingEnergy != nil
    }

    var hasLeanBodyMass: Bool {
        lbm != nil
    }

    var hasDynamicRestingEnergy: Bool {
        restingEnergySource == .healthApp
        || (restingEnergySource == .formula && restingEnergyUsesHealthMeasurements)
    }
    
    var hasDynamicLeanBodyMass: Bool {
        lbmSource == .healthApp
        || (lbmSource == .formula && lbmUsesHealthMeasurements)
    }

}

extension TDEEForm.ViewModel {
    
    var restingEnergyIntervalValues: [Int] {
        Array(restingEnergyInterval.minValue...restingEnergyInterval.maxValue)
    }

    var lbmSourceBinding: Binding<LeanBodyMassSourceOption> {
        Binding<LeanBodyMassSourceOption>(
            get: { self.lbmSource ?? .userEntered },
            set: { newSource in
                Haptics.feedback(style: .soft)
                self.changeLBMSoruce(to: newSource)
            }
        )
    }

    func changeWeightSource(to newSource: MeasurementSourceOption) {
        withAnimation {
            weightSource = newSource
        }
        if newSource == .healthApp {
            fetchWeightFromHealth()
        }
    }

    func changeLBMSoruce(to newSource: LeanBodyMassSourceOption) {
        withAnimation {
            lbmSource = newSource
        }
    }
    
    var restingEnergySourceBinding: Binding<RestingEnergySourceOption> {
        Binding<RestingEnergySourceOption>(
            get: { self.restingEnergySource ?? .userEntered },
            set: { newSource in
                Haptics.feedback(style: .soft)
                self.changeRestingEnergySource(to: newSource)
            }
        )
    }
    
    var restingEnergyTextFieldStringBinding: Binding<String> {
        Binding<String>(
            get: { self.restingEnergyTextFieldString },
            set: { newValue in
                guard !newValue.isEmpty else {
                    self.restingEnergy = nil
                    self.restingEnergyTextFieldString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.restingEnergy = double
                withAnimation {
                    self.restingEnergyTextFieldString = newValue
                }
            }
        )
    }
    
    var lbmTextFieldStringBinding: Binding<String> {
        Binding<String>(
            get: { self.lbmTextFieldString },
            set: { newValue in
                guard !newValue.isEmpty else {
                    self.lbm = nil
                    self.lbmTextFieldString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.lbm = double
                withAnimation {
                    self.lbmTextFieldString = newValue
                }
            }
        )
    }
    
    func changeRestingEnergySource(to newSource: RestingEnergySourceOption) {
        withAnimation {
            restingEnergySource = newSource
        }
        switch restingEnergySource {
        case .healthApp:
            fetchRestingEnergyFromHealth()
        default:
            break
        }
    }
    
    var restingEnergyFormulaBinding: Binding<RestingEnergyFormula> {
        Binding<RestingEnergyFormula>(
            get: { self.restingEnergyFormula },
            set: { newFormula in
                Haptics.feedback(style: .soft)
                self.changeRestingEnergyFormula(to: newFormula)
            }
        )
    }
    
    func changeRestingEnergyFormula(to newFormula: RestingEnergyFormula) {
        withAnimation {
            self.restingEnergyFormula = newFormula
        }
    }
    
    var restingEnergyPeriodBinding: Binding<HealthPeriodOption> {
        Binding<HealthPeriodOption>(
            get: { self.restingEnergyPeriod },
            set: { newPeriod in
                Haptics.feedback(style: .soft)
                self.changeRestingEnergyPeriod(to: newPeriod)
            }
        )
    }

    func changeRestingEnergyPeriod(to newPeriod: HealthPeriodOption) {
        withAnimation {
            self.restingEnergyPeriod = newPeriod
            if newPeriod == .previousDay {
                restingEnergyIntervalValue = 1
                restingEnergyInterval = .day
            } else {
                correctRestingEnergyIntervalValueIfNeeded()
            }
        }
        fetchRestingEnergyFromHealth()
    }
    
    var restingEnergyIntervalValueBinding: Binding<Int> {
        Binding<Int>(
            get: { self.restingEnergyIntervalValue },
            set: { newValue in
                Haptics.feedback(style: .soft)
                self.changeRestingEnergyIntervalValue(to: newValue)
            }
        )
    }
    
    func changeRestingEnergyIntervalValue(to newValue: Int) {
        guard newValue >= restingEnergyInterval.minValue,
              newValue <= restingEnergyInterval.maxValue else {
            return
        }
        withAnimation {
            restingEnergyIntervalValue = newValue
        }
        fetchRestingEnergyFromHealth()
    }
    var restingEnergyIntervalBinding: Binding<HealthAppInterval> {
        Binding<HealthAppInterval>(
            get: { self.restingEnergyInterval },
            set: { newInterval in
                Haptics.feedback(style: .soft)
                self.changeRestingEnergyInterval(to: newInterval)
            }
        )
    }
    
    func changeRestingEnergyInterval(to newInterval: HealthAppInterval) {
        withAnimation {
            restingEnergyInterval = newInterval
            correctRestingEnergyIntervalValueIfNeeded()
        }
        
        fetchRestingEnergyFromHealth()
    }
    
    func correctRestingEnergyIntervalValueIfNeeded() {
        if restingEnergyIntervalValue < restingEnergyInterval.minValue {
            restingEnergyIntervalValue = restingEnergyInterval.minValue
        }
        if restingEnergyIntervalValue > restingEnergyInterval.maxValue {
            restingEnergyIntervalValue = restingEnergyInterval.maxValue
        }
    }

    var maintenanceEnergyFooterText: Text {
        let energy = userEnergyUnit == .kcal ? "calories" : "kiljoules"
        return Text("This is an estimate of how many \(energy) you would have to consume to *maintain* your current weight.")
    }
    
    var restingEnergyFooterString: String? {
        let prefix = "This is an estimate of the energy your body uses each day while minimally active."
        if restingEnergySource == .healthApp {
            return prefix + " This will sync with your Health data and update daily."
        }
        return prefix
    }
    
    func updateHealthAppData() {
        fetchRestingEnergyFromHealth()
    }

    func fetchWeightFromHealth() {
        withAnimation {
            weightFetchStatus = .fetching
        }
        
        Task {
            guard let (weight, weightDate) = await HealthKitManager.shared.latestWeight() else {
                return
            }
            if Date().numberOfDaysFrom(weightDate) > MaximumNumberOfDaysForWeight {
                //TODO: ask user if they would like to old measurement
            }
            await MainActor.run {
                withAnimation {
                    self.weight = weight
                    self.weightTextFieldString = weight.cleanAmount
                    self.weightDate = weightDate
                }
            }
        }
    }
    
    func fetchRestingEnergyFromHealth() {
        withAnimation {
            restingEnergyFetchStatus = .fetching
        }
        
        Task {
            do {
                guard let average = try await HealthKitManager.shared.averageSumOfRestingEnergy(
                    using: userEnergyUnit,
                    overPast: restingEnergyIntervalValue,
                    interval: restingEnergyInterval
                ) else {
                    restingEnergyFetchStatus = .notAuthorized
                    return
                }
                await MainActor.run {
                    withAnimation {
                        print("🔥 setting average: \(average)")
                        restingEnergy = average
                        restingEnergyTextFieldString = "\(Int(average))"
                        restingEnergyFetchStatus = .fetched
                    }
                }
            } catch HealthKitManagerError.couldNotGetSumQuantity {
                /// Indicates that permissions are not present
                await MainActor.run {
                    withAnimation {
                        restingEnergyFetchStatus = .notAuthorized
                    }
                }
            } catch {
                
            }
            /// [ ] Make sure we persist this to the backend once the user saves it
        }
    }
}
