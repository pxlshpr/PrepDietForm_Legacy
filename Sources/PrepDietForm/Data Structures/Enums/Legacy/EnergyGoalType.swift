import Foundation

public enum EnergyGoalType: Int16, Hashable, Codable, CaseIterable {
    case fixed
    case percentage
    
    //TODO: Use user's units instead of kcal
    var shortDescription: String {
        switch self {
        case .fixed:        return "kcal"
        case .percentage:   return "%"
        }
    }
    
    //TODO: Use user's units instead of kcal
    var description: String {
        switch self {
        case .fixed:        return "kcal"
        case .percentage:   return "percentage"
        }
    }
    
    var systemImage: String {
        switch self {
        case .fixed:        return "flame"
        case .percentage:   return "percent"
        }
    }
}

public enum EnergyGoalDifference: Int16, Hashable, Codable, CaseIterable {
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
