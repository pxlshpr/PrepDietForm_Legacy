import PrepDataTypes

public enum WorkoutDurationUnit: Int16, Codable, CaseIterable {
    case min = 1
    case hour
    
    var pickerDescription: String {
        switch self {
        case .min:
            return "minute"
        case .hour:
            return "hour"
        }
    }
    
    var menuDescription: String {
        switch self {
        case .min:
            return "minute"
        case .hour:
            return "hour"
        }
    }
}

public enum MacroGoalType: Codable, Hashable {
    
    case fixed
    
    /// Only used with Diets
    case gramsPerBodyMass(BodyMass, WeightUnit)
    case percentageOfEnergy
    
    /// Only used for meal profiles, for things like pre-workout meals
    case gramsPerWorkoutDuration(WorkoutDurationUnit)
}

extension MacroGoalType {
    
    var description: String {
        switch self {
        case .fixed:
            return "g"
        case .gramsPerBodyMass(_, let weightUnit):
            return "g per \(weightUnit.shortDescription)"
        case .percentageOfEnergy:
            return "% of energy"
        case .gramsPerWorkoutDuration(let workoutDurationUnit):
            return "g per \(workoutDurationUnit.menuDescription)"
        }
    }
    
    var accessoryDescription: String? {
        switch self {
        case .fixed:
            return nil
        case .percentageOfEnergy:
            return "of energy goal"
        case .gramsPerBodyMass(let bodyMass, _):
            return "of \(bodyMass.description)"
        case .gramsPerWorkoutDuration(_):
            return "of workout time"
        }
    }
    
    var accessorySystemImage: String? {
        switch self {
        case .fixed:
            return nil
        case .percentageOfEnergy:
            return "percent"
        case .gramsPerBodyMass(_, _):
            return "figure.arms.open"
        case .gramsPerWorkoutDuration(_):
            return "clock"
        }
    }
    
    var usesWeight: Bool {
        switch self {
        case .gramsPerBodyMass:
            return true
        default:
            return false
        }
    }
    
    var isPercent: Bool {
        switch self {
        case .percentageOfEnergy:
            return true
        default:
            return false
        }
    }
    
    var isGramsPerMinutesOfExercise: Bool {
        switch self {
        case .gramsPerWorkoutDuration:
            return true
        default:
            return false
        }
    }
    
    var isGrams: Bool {
        isFixedGrams || isGramsPerBodyMass
    }
    
    var isGramsPerBodyMass: Bool {
        switch self {
        case .gramsPerBodyMass:
            return true
        default:
            return false
        }
    }
    
    var isFixedGrams: Bool {
        switch self {
        case .fixed:
            return true
        default:
            return false
        }
    }

}

extension MacroGoalType {
    var bodyMassType: BodyMass? {
        get {
            switch self {
            case .gramsPerBodyMass(let bodyMassType, _):
                return bodyMassType
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch self {
            case .gramsPerBodyMass(_, let weightUnit):
                self = .gramsPerBodyMass(newValue, weightUnit)
            default:
                break
            }
        }
    }
    
    var bodyMassWeightUnit: WeightUnit? {
        get {
            switch self {
            case .gramsPerBodyMass(_, let weightUnit):
                return weightUnit
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch self {
            case .gramsPerBodyMass(let bodyMassType, _):
                self = .gramsPerBodyMass(bodyMassType, newValue)
            default:
                break
            }
        }
    }
}
