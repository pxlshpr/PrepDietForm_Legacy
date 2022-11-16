import SwiftUI
import PrepDataTypes

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
}

extension TDEEForm.ViewModel {
    func fetchRestingEnergyFromHealth() {
        restingEnergyFetchStatus = .fetching
        
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
                        restingEnergyFetchStatus = .fetched
                    }
                }
            } catch HealthKitManagerError.couldNotGetSumQuantity {
                /// Indicates that permissions are not present
                withAnimation {
                    restingEnergyFetchStatus = .notAuthorized
                }
            } catch {
                
            }
            /// [ ] Make sure we persist this to the backend once the user saves it
        }
    }
}
