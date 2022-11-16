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
    
    var hasDynamicRestingEnergy: Bool {
        restingEnergySource == .healthApp
        || (restingEnergySource == .formula && restingEnergyUsesHealthMeasurements)
    }
}

extension TDEEForm.ViewModel {
    
    var restingEnergyIntervalValues: [Int] {
        Array(restingEnergyInterval.minValue...restingEnergyInterval.maxValue)
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
    
    func changeRestingEnergySource(to newSource: RestingEnergySourceOption) {
        withAnimation {
            restingEnergySource = newSource
        }
        if restingEnergySource == .healthApp {
            fetchRestingEnergyFromHealth()
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
