import Foundation

public enum MicroGoalType: Codable, Hashable {
    case fixed
    
    /// Only used for meal profiles, for things like pre-workout meals.
    case quantityPerWorkoutDuration(WorkoutDurationUnit)
}
