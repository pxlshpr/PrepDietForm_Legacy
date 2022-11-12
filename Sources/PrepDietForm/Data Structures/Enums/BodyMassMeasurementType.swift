import Foundation

public enum BodyMassType: Int16, Hashable, Codable {
    case weight = 1
    case leanMass
    
    var description: String {
        switch self {
        case .weight:
            return "weight"
        case .leanMass:
            return "lean body mass"
        }
    }
}
