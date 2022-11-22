import PrepDataTypes

public enum NutrientGoalType: Codable, Hashable {
    
    case fixed
    
    /// Only used with Diets
    case quantityPerBodyMass(BodyMass, WeightUnit)
    case percentageOfEnergy
    case quantityPerEnergy(Double, EnergyUnit) /// `Double` indicates the value we're using

    /// Only used for meal profiles, for things like pre-workout meals
    case quantityPerWorkoutDuration(WorkoutDurationUnit)
}

extension NutrientGoalType {
    
    func description(nutrientUnit: NutrientUnit) -> String {
        switch self {
        case .fixed:
            return "\(nutrientUnit.shortDescription)"
        case .quantityPerBodyMass(_, let weightUnit):
            return "\(nutrientUnit.shortDescription) per \(weightUnit.shortDescription)"
        case .percentageOfEnergy:
            return "%"
        case .quantityPerWorkoutDuration(let workoutDurationUnit):
            return "\(nutrientUnit.shortDescription) per \(workoutDurationUnit.menuDescription)"
        case .quantityPerEnergy:
            return "\(nutrientUnit.shortDescription)"
        }
    }
    
    var accessoryDescription: String? {
        switch self {
        case .fixed:
            return nil
        case .percentageOfEnergy:
            return "of energy goal"
        case .quantityPerBodyMass(let bodyMass, _):
            return "of \(bodyMass.description)"
        case .quantityPerWorkoutDuration(_):
            return "of workout time"
        case .quantityPerEnergy(let energyValue, let energyUnit):
            return "per \(energyValue.cleanAmount) \(energyUnit.shortDescription)"
        }
    }
    
    var accessorySystemImage: String? {
        switch self {
        case .fixed:
            return nil
        case .percentageOfEnergy, .quantityPerEnergy:
            return "flame.fill"
        case .quantityPerBodyMass(_, _):
            return "figure.arms.open"
        case .quantityPerWorkoutDuration(_):
            return "clock"
        }
    }
    
    var usesWeight: Bool {
        switch self {
        case .quantityPerBodyMass:
            return true
        default:
            return false
        }
    }
    
    var isPercentageOfEnergy: Bool {
        switch self {
        case .percentageOfEnergy:
            return true
        default:
            return false
        }
    }
    
    var isGramsPerMinutesOfExercise: Bool {
        switch self {
        case .quantityPerWorkoutDuration:
            return true
        default:
            return false
        }
    }
    
    var isQuantityPerEnergy: Bool {
        switch self {
        case .quantityPerEnergy:
            return true
        default:
            return false
        }
    }
    
    var dependsOnEnergy: Bool {
        switch self {
        case .percentageOfEnergy, .quantityPerEnergy:
            return true
        default:
            return false
        }
    }
    
    var isQuantityPerBodyMass: Bool {
        switch self {
        case .quantityPerBodyMass:
            return true
        default:
            return false
        }
    }
    
    var isFixedQuantity: Bool {
        switch self {
        case .fixed:
            return true
        default:
            return false
        }
    }

}

extension NutrientGoalType {
    var bodyMassType: BodyMass? {
        get {
            switch self {
            case .quantityPerBodyMass(let bodyMassType, _):
                return bodyMassType
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch self {
            case .quantityPerBodyMass(_, let weightUnit):
                self = .quantityPerBodyMass(newValue, weightUnit)
            default:
                break
            }
        }
    }
    
    var bodyMassWeightUnit: WeightUnit? {
        get {
            switch self {
            case .quantityPerBodyMass(_, let weightUnit):
                return weightUnit
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch self {
            case .quantityPerBodyMass(let bodyMassType, _):
                self = .quantityPerBodyMass(bodyMassType, newValue)
            default:
                break
            }
        }
    }
}
