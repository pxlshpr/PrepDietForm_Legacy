import PrepDataTypes

public enum EnergyGoalUnit: Int16, Hashable, Codable {
    case kcal
    case kj
    case percent
    
    var shortDescription: String {
        switch self {
        case .kcal:     return "kcal"
        case .kj:       return "kJ"
        case .percent:  return "%"
        }
    }
    
    var energyGoalType: EnergyGoalType {
        switch self {
        case .kcal, .kj:
            return .fixed
        case .percent:
            return .percentage
        }
    }
    
    init(energyUnit: EnergyUnit) {
        switch energyUnit {
        case .kcal:
            self = .kcal
        case .kJ:
            self = .kj
        }
    }
    
    init(energyGoalType: EnergyGoalType) {
        switch energyGoalType {
        case .fixed:
            self = .kcal //TODO: Use user's units
        case .percentage:
            self = .percent
        }
    }
}
