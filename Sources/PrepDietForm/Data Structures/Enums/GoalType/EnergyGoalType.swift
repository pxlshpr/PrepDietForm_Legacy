import Foundation
import PrepDataTypes

public enum EnergyGoalType: Hashable, Codable {
    case fixed(EnergyUnit)
    
    /// Only used with diets
    case fromMaintenance(EnergyUnit, Delta)
    case percentFromMaintenance(Delta)
        
    /// Only used with meal. Describes the percent of the diet goal to use for this.So that we could indicate we want a meal to be 1/3rd of 1/6th of the day's total.
    case percentOfDietGoal
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
            .fixed(energyUnit),
            .percentOfDietGoal
        ]
    }
}

public extension EnergyGoalType {
    
    //TODO: Use user's units instead of kcal
    var shortDescription: String {
        switch self {
        case .fixed(let energyUnit):
            return energyUnit.shortDescription
        case .fromMaintenance(let energyUnit, _):
            return energyUnit.shortDescription
        case .percentFromMaintenance:
            return "%"
        case .percentOfDietGoal:
            return "% of day's total"
        }
    }
    
    //TODO: Use user's units instead of kcal
    var description: String {
        switch self {
        case .fixed(let energyUnit):
            return energyUnit.shortDescription
        case .fromMaintenance(let energyUnit, _):
            return energyUnit.shortDescription
        case .percentFromMaintenance:
            return "percentage"
        case .percentOfDietGoal:
            return "percentage of day's total"
        }
    }
    
    var systemImage: String {
        switch self {
        case .fixed, .fromMaintenance:
            return "flame"
        case .percentFromMaintenance, .percentOfDietGoal:
            return "percent"
        }
    }
    
    var deltaDescription: String? {
        delta?.description
    }
    
    var deltaSystemImage: String? {
        delta?.systemImage
    }
    
    var delta: Delta? {
        get {
            switch self {
            case .fromMaintenance(_, let energyDelta):
                return energyDelta
            case .percentFromMaintenance(let energyDelta):
                return energyDelta
            default:
                return nil
            }
        }
        set {
            switch self {
            case .fromMaintenance(let energyUnit, _):
                guard let newValue else {
                    /// set it to fixed if we've assigned `nil`
                    self = .fixed(energyUnit)
                    return
                }
                self = .fromMaintenance(energyUnit, newValue)
            case .percentFromMaintenance(_):
                guard let newValue else {
                    //TODO: Use the user's default unit here
                    /// set it to fixed with the user's default unit if we've assigned `nil`
                    self = .fixed(.kcal)
                    return
                }
                self = .percentFromMaintenance(newValue)
            default:
                break
            }
        }
    }
}