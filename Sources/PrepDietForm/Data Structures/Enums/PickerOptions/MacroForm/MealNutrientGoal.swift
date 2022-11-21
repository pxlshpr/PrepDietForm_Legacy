import Foundation

enum MealNutrientGoal: CaseIterable {
    case fixed
    case quantityPerWorkoutDuration
    
    init?(goalViewModel: GoalViewModel) {
        switch goalViewModel.nutrientGoalType {
        case .fixed:
            self = .fixed
        case .quantityPerWorkoutDuration:
            self = .quantityPerWorkoutDuration
        default:
            return nil
        }
    }
    
    var menuDescription: String {
        switch self {
        case .fixed:
            return "grams"
        case .quantityPerWorkoutDuration:
            return "grams / workout duration"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .fixed:
            return "g"
        case .quantityPerWorkoutDuration:
            return "g"
        }
    }
}
