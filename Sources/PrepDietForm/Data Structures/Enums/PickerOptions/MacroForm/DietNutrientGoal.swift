import Foundation

enum DietNutrientGoal: CaseIterable {
    case fixed
    case quantityPerBodyMass
    case percentageOfEnergy
    
    init?(goalViewModel: GoalViewModel) {
        switch goalViewModel.nutrientGoalType {
        case .fixed:
            self = .fixed
        case .quantityPerBodyMass:
            self = .quantityPerBodyMass
        case .percentageOfEnergy:
            self = .percentageOfEnergy
        default:
            return nil
        }
    }
    
    var menuDescription: String {
        switch self {
        case .fixed:
            return "grams"
        case .quantityPerBodyMass:
            return "grams / body mass"
        case .percentageOfEnergy:
            return "% of energy"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .fixed, .quantityPerBodyMass:
            return "g"
        case .percentageOfEnergy:
            return "% of energy"
        }
    }
}
