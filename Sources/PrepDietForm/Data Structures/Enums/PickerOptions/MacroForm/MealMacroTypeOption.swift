import Foundation

enum MealMacroTypeOption: CaseIterable {
    case fixed
    case gramsPerWorkoutDuration
    
    init?(goalViewModel: GoalViewModel) {
        switch goalViewModel.macroGoalType {
        case .fixed:
            self = .fixed
        case .quantityPerWorkoutDuration:
            self = .gramsPerWorkoutDuration
        default:
            return nil
        }
    }
    
    var menuDescription: String {
        switch self {
        case .fixed:
            return "grams"
        case .gramsPerWorkoutDuration:
            return "grams / workout duration"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .fixed:
            return "g"
        case .gramsPerWorkoutDuration:
            return "g"
        }
    }
}
