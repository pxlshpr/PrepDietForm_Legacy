import SwiftUI
import PrepDataTypes

public enum GoalType: Hashable, Codable {
    
    case energy(EnergyGoalType)
    
    case macro(MacroGoalType, Macro)
    
    /// The bool at the end indicates whether the micronutrient is ignored for meal-wise splits.
    /// This is useful for things like vitamins and minerals which we may not want to create automatic meal-split goals for unless the user explicitly specifies so.
    case micro(MicroGoalType, NutrientType, NutrientUnit, Bool)
    
    /// A hash value that is independent of the associated values
    var identifyingHashValue: String {
        switch self {
        case .energy:
            return "energy"
        case .macro(_, let macro):
            return "macro_\(macro.rawValue)"
        case .micro(_, let nutrientType, _, _):
            return "macro_\(nutrientType.rawValue)"
        }
    }
    
    var isMacro: Bool {
        macro != nil
    }
    var isMicro: Bool {
        nutrientType != nil
    }

    var isEnergy: Bool {
        switch self {
        case .energy:   return true
        default:        return false
        }
    }
    
    var macro: Macro? {
        switch self {
        case .macro(_, let macro):  return macro
        default:                    return nil
        }
    }
    
    var nutrientType: NutrientType? {
        switch self {
        case .micro(_, let nutrientType, _, _):
            return nutrientType
        default:
            return nil
        }
    }
    
    var systemImage: String {
        switch self {
        case .energy:
            return "flame.fill"
        case .macro:
            return "circle.circle.fill"
        case .micro:
            return "circle.circle"
        }
    }
    
    var name: String {
        switch self {
        case .energy:
            return "Energy"
        case .macro(_, let macro):
            return macro.description
        case .micro(_, let nutrientType, _, _):
            return nutrientType.description
        }
    }
    
    func labelColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .energy:
            return .accentColor
        case .macro(_, let macro):
            return macro.textColor(for: colorScheme)
        case .micro:
            return .gray
        }
    }
    
    var unitString: String {
        switch self {
        case .energy(let type):
            return type.description
        case .macro:
            return "g"
        case .micro(_, _, let nutrientUnit, _):
            return nutrientUnit.shortDescription
        }
    }
    
    var showsEquivalentValues: Bool {
        switch self {
        case .energy(let energyGoalType):
            switch energyGoalType {
            case .fromMaintenance, .percentFromMaintenance:
                return true
            default:
                return false
            }
        case .macro(let macroGoalType, let macro):
            //TODO: Revisit this
            return false
        case .micro(let microGoalType, let nutrientType, let nutrientUnit, _):
            //TODO: Revisit this
            return false
        }
    }
    

    var accessoryDescription: String? {
        switch self {
        case .energy(let type):
            return type.accessoryDescription
        case .macro:
            return nil
        case .micro:
            return nil
        }
    }
    
    var accessorySystemImage: String? {
        switch self {
        case .energy(let type):
            return type.accessorySystemImage
        default:
            return nil
        }
    }
    
}
