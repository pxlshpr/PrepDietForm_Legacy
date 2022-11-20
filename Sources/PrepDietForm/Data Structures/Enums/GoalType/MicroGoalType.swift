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
            return "\(nutrientUnit.shortDescription)"
        case .quantityPerWorkoutDuration(let durationUnit):
            return "\(nutrientUnit.shortDescription) per \(durationUnit.menuDescription)"
        }
    }
    
    
    var accessoryDescription: String? {
        switch self {
        case .fixed:
            return nil
        case .quantityPerWorkoutDuration(_):
            return "of workout time"
        }
    }
    
    var accessorySystemImage: String? {
        switch self {
        case .fixed:
            return nil
        case .quantityPerWorkoutDuration(_):
            return "clock"
        }
    }
}
