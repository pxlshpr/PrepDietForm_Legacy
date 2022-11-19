import PrepDataTypes

public enum MacroGoalType: Codable, Hashable {
    
    case fixed
    
    /// Only used with Diets
    case gramsPerBodyMass(BodyMass, WeightUnit)
    case percentageOfEnergy
    
    /// Only used for meal profiles, for things like pre-workout meals. The planned activity duration is included so that we can make this calculation.
    case gramsPerMinutesOfActivity(Double)

    static var units: [(NutrientUnit, String)] {
        [
            (.g, "scalemass.fill"),
            (.p, "percent")
        ]
    }
}

extension MacroGoalType {
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
        case .gramsPerMinutesOfActivity:
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
