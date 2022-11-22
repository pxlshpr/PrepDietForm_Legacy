import Foundation
import PrepDataTypes

public enum EnergyGoalType: Hashable, Codable {
    case fixed(EnergyUnit)
    
    /// Only used with diets
    case fromMaintenance(EnergyUnit, Delta)
    case percentFromMaintenance(Delta)
}

extension EnergyGoalType {
    static func defaultDietTypes(userEnergyUnit energyUnit: EnergyUnit) -> [EnergyGoalType] {
        [
            .fixed(energyUnit),
            .fromMaintenance(energyUnit, .deficit),
            .percentFromMaintenance(.deficit)
        ]
    }
    
    static func defaultMealTypes(userEnergyUnit energyUnit: EnergyUnit) -> [EnergyGoalType] {
        [
            .fixed(energyUnit)
        ]
    }
}

public extension EnergyGoalType {
    
    var description: String {
        switch self {
        case .fixed(let energyUnit):
            return energyUnit.shortDescription
        case .fromMaintenance(let energyUnit, _):
            return energyUnit.shortDescription
        case .percentFromMaintenance:
            return "%"
        }
    }
    
    var systemImage: String {
        switch self {
        case .fixed, .fromMaintenance:
            return "flame"
        case .percentFromMaintenance:
            return "percent"
        }
    }
    
    var accessoryDescription: String? {
        switch self {
        case .fixed:
            return nil
        case .fromMaintenance(_, let delta):
            return delta.description
        case .percentFromMaintenance(let delta):
            return delta.description
        }
    }
    
    var accessorySystemImage: String? {
        switch self {
        case .fixed:
            return nil
        case .fromMaintenance(_, let delta):
            return delta.systemImage
        case .percentFromMaintenance(let delta):
            return delta.systemImage
        }
    }
    
    var delta: Delta? {
        switch self {
        case .fromMaintenance(_, let energyDelta):
            return energyDelta
        case .percentFromMaintenance(let energyDelta):
            return energyDelta
        default:
            return nil
        }
    }
}
