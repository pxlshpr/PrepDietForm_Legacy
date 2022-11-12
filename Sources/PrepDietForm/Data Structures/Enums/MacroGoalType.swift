import PrepDataTypes

public enum MacroGoalType: Codable, Hashable {
    case fixed
    case gramsPerBodyMass(BodyMassType, WeightUnit)
    case percentageOfEnergy
    
    /// Only used for meal profiles, for things like pre-workout meals. The planned activity duration is included so that we can make this calculation.
    case gramsPerMinutesOfActivity
    
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
}

extension MacroGoalType {
    var bodyMassType: BodyMassType? {
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
