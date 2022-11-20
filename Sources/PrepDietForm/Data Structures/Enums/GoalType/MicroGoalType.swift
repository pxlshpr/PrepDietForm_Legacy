import Foundation
import PrepDataTypes

public enum MicroGoalType: Codable, Hashable {
    case fixed
    
    /// Only used for meal profiles, for things like pre-workout meals.
    case quantityPerWorkoutDuration(WorkoutDurationUnit)
}

extension MicroGoalType {
    func description(nutrientUnit: NutrientUnit) -> String {
        switch self {
        case .fixed:
            return "g"
        case .quantityPerWorkoutDuration(let durationUnit):
            return "\(nutrientUnit.shortDescription)/\(durationUnit.menuDescription) of workout"
        }
    }
}
