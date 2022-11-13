import Foundation

public enum ActivityLevel: Int16, Codable, Hashable, CaseIterable {

    case notSet
    case sedentary
    case lightlyActive
    case moderatelyActive
    case active
    case veryActive
    
    var description: String {
        switch self {
        case .notSet:           return "Do not use"
        case .sedentary:        return "Sedentary"
        case .lightlyActive:    return "Lightly Active"
        case .moderatelyActive: return "Moderately Active"
        case .active:           return "Active"
        case .veryActive:       return "Very Active"
        }
    }
    
    var scaleFactor: Double {
        switch self {
        case .notSet:           return 1
        case .sedentary:        return 1.2
        case .lightlyActive:    return 1.375
        case .moderatelyActive: return 1.55
        case .active:           return 1.725
        case .veryActive:       return 1.9
        }
    }
}
