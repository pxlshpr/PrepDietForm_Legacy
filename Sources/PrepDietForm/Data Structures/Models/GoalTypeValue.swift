import Foundation
import PrepDataTypes

public struct GoalTypeValue: Codable, Hashable {
    public var flattenedType: FlattenedGoalType
    
    public var energyUnit: EnergyUnit?
    public var energyDelta: EnergyGoalType.Delta?
    public var macro: Macro?
    public var nutrientType: NutrientType?
    public var nutrientUnit: NutrientUnit?
    
    public var bodyMass: NutrientGoalType.BodyMass?
    public var weightUnit: WeightUnit?
    public var energyQuantity: Double?
    public var workoutDurationUnit: WorkoutDurationUnit?
}

public enum FlattenedGoalType: Int16, Codable, Hashable {
    
    case energyFixed = 1
    case energyFromMaintenance
    case energyPercentageFromMaintenance

    case nutrientFixed = 100
    case nutrientQuantityPerBodyMass
    case nutrientQuantityPerEnergy
    case nutrientPercentageOfEnergy
    case nutrientQuantityPerWorkoutDuration
}
