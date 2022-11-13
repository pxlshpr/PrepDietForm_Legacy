import Foundation
import PrepDataTypes

enum MealEnergyTypeOption: CaseIterable {
    
    case fixed
    case percentageOfDailyTotal
    
    func description(userEnergyUnit energyUnit: EnergyUnit) -> String {
        switch self {
        case .fixed: return energyUnit.shortDescription
        case .percentageOfDailyTotal: return "% of daily total"
        }
    }
    
    init?(goalViewModel: GoalViewModel) {
        switch goalViewModel.energyGoalType {
        case .percentOfDietGoal:
            self = .percentageOfDailyTotal
        case .fixed:
            self = .fixed
        default:
            return nil
        }
    }
}
