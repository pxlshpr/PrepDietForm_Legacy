import SwiftUI
import PrepDataTypes

extension TDEEForm {
    class ViewModel: ObservableObject {
        let userEnergyUnit: EnergyUnit
        
        @Published var hasAppeared = false
        @Published var activeEnergySource: ActiveEnergySourceOption? = nil
        
        @Published var isEditing = false
        @Published var presentationDetent: PresentationDetent = .height(270)
        @Published var restingEnergySource: RestingEnergySourceOption? = nil
//        @Published var isEditing = true
//        @Published var presentationDetent: PresentationDetent = .large
//        @Published var restingEnergySource: RestingEnergySourceOption? = .healthApp
        
        @Published var restingEnergy: Double? = nil
        @Published var fetchedRestingEnergy: Bool = false
        
        @Published var restingEnergyPeriod: HealthPeriodOption = .average
        @Published var restingEnergyIntervalValue: Int = 1
        @Published var restingEnergyInterval: HealthAppInterval = .week
        
        init(userEnergyUnit: EnergyUnit) {
            self.userEnergyUnit = userEnergyUnit
        }
    }
}

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
    
    var failedToFetchRestingEnergy: Bool {
        fetchedRestingEnergy && !hasRestingEnergy
    }
    
    var hasRestingEnergy: Bool {
        restingEnergy != nil
    }
}

extension TDEEForm.ViewModel {
    func fetchRestingEnergyFromHealth() {
        Task {
            /// [ ] Do this in the ViewModel
            /// [ ] Store the energyUnit in the view model
            /// [ ] Get the default range here (daily average of past week for resting energy)
            guard let average = try await HealthKitManager.shared.averageSumOfRestingEnergy(
                using: userEnergyUnit,
                overPast: restingEnergyIntervalValue,
                interval: restingEnergyInterval
            ) else {
                /// [ ] If we got nothing, show the empty state with a hint that they might need to give permissions
                return
            }
            await MainActor.run {
                withAnimation {
                    restingEnergy = average
                }
            }
            
            /// [ ] Make sure we persist this to the backend once the user saves it
        }
    }
}
