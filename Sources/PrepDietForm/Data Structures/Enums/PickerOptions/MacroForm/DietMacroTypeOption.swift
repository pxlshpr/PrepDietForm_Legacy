import Foundation

enum DietMacroTypeOption: CaseIterable {
    case fixed
    case gramsPerBodyMass
    case percentageOfEnergy
    
    init?(goalViewModel: GoalViewModel) {
        switch goalViewModel.macroGoalType {
        case .fixed:
            self = .fixed
        case .quantityPerBodyMass:
            self = .gramsPerBodyMass
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
        case .gramsPerBodyMass:
            return "grams / body mass"
        case .percentageOfEnergy:
            return "% of energy"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .fixed, .gramsPerBodyMass:
            return "g"
        case .percentageOfEnergy:
            return "% of energy"
        }
    }
}
