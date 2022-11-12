import SwiftUI
import PrepDataTypes

public enum GoalType: Hashable, Codable {
    case energy(EnergyGoalType)
    case macro(MacroGoalType, Macro)
    case micro(MicroGoalType, NutrientType, NutrientUnit)
    
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
        case .micro(_, let nutrientType, _):    return nutrientType
        default:                                return nil
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
            return type.shortDescription
        case .macro:
            return "g"
        case .micro(_, _, let nutrientUnit):
            return nutrientUnit.shortDescription
        }
    }
    
    var relativeString: String? {
        switch self {
        case .energy(let type):
            return type.deltaDescription
        case .macro:
            return nil
        case .micro:
            return nil
        }
    }
    
    var differenceSystemImage: String? {
        switch self {
        case .energy(let type):
            return type.deltaSystemImage
        default:
            return nil
        }
    }
    
}