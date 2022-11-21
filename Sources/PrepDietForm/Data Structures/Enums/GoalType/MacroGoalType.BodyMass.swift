import Foundation

public extension NutrientGoalType {
    enum BodyMass: Int16, Hashable, Codable, CaseIterable {
        case weight = 1
        case leanMass
    }
}

public extension NutrientGoalType.BodyMass {
    
    var description: String {
        switch self {
        case .weight:
            return "weight"
        case .leanMass:
            return "lean body mass"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .weight:
            return "body weight"
        case .leanMass:
            return "lean body mass"
        }
    }
    
    var pickerPrefix: String {
        "of "
    }
    
    var  menuDescription: String {
        switch self {
        case .weight:
            return "body weight"
        case .leanMass:
            return "lean body mass"
        }
    }
}
