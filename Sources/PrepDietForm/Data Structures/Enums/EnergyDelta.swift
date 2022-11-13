import Foundation

public enum EnergyDelta: Int16, Hashable, Codable, CaseIterable {
    case surplus
    case deficit
    
    var description: String {
        switch self {
        case .deficit:  return "below maintenance"
        case .surplus:  return "above maintenance"
        }
    }
    
    var systemImage: String {
        switch self {
        case .deficit:  return "arrow.turn.right.down" // "minus.diamond"
        case .surplus:  return "arrow.turn.right.up" //"plus.diamond"
        }
    }
}

extension EnergyDelta {
    var deltaPickerOption: EnergyDeltaOption {
        switch self {
        case .surplus:
            return .above
        case .deficit:
            return .below
        }
    }
}
