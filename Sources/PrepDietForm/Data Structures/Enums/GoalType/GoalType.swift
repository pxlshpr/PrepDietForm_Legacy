import SwiftUI
import PrepDataTypes

public enum GoalType: Hashable, Codable {
    
    case energy(EnergyGoalType)
    
    case macro(NutrientGoalType, Macro)
    
    case micro(NutrientGoalType, NutrientType, NutrientUnit)
    
    /// A hash value that is independent of the associated values
    var identifyingHashValue: String {
        switch self {
        case .energy:
            return "energy"
        case .macro(_, let macro):
            return "macro_\(macro.rawValue)"
        case .micro(_, let nutrientType, _):
            return "macro_\(nutrientType.rawValue)"
        }
    }
    
    var isMacro: Bool {
        macro != nil
    }
    var isMicro: Bool {
        nutrientType != nil
    }
    
    var dependsOnEnergy: Bool {
        nutrientGoalType?.dependsOnEnergy ?? false
    }
    
    var nutrientGoalType: NutrientGoalType? {
        switch self {
        case .macro(let nutrientGoalType, _):
            return nutrientGoalType
        case .micro(let nutrientGoalType, _, _):
            return nutrientGoalType
        default:
            return nil
        }
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
        case .micro(_, let nutrientType, _):
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
        case .micro(_, let nutrientType, _):
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
        case .macro(let type, _):
            return type.description(nutrientUnit: .g)
        case .micro(let type, _, let nutrientUnit):
            return type.description(nutrientUnit: nutrientUnit)
        }
    }
    
    var showsEquivalentValues: Bool {
        switch self {
        case .energy(let energyGoalType):
            switch energyGoalType {
            case .fixed:
                return false
            default:
                return true
            }
        case .macro(let macroGoalType, _):
            switch macroGoalType {
            case .fixed:
                return false
            default:
                return true
            }
        case .micro(let microGoalType, _, _):
            switch microGoalType {
            case .fixed:
                return false
            default:
                return true
            }
        }
    }
    
    var accessoryDescription: String? {
        switch self {
        case .energy(let type):
            return type.accessoryDescription
        case .macro(let type, _):
            return type.accessoryDescription
        case .micro(let type, _, _):
            return type.accessoryDescription
        }
    }
    
    var accessorySystemImage: String? {
        switch self {
        case .energy(let type):
            return type.accessorySystemImage
        case .macro(let type, _):
            return type.accessorySystemImage
        case .micro(let type, _, _):
            return type.accessorySystemImage
        }
    }
    
}
