import Foundation

enum RestingEnergySourceOption: Int16, Codable, CaseIterable {
    case healthApp = 1
    case formula
    case userEntered
    
    var pickerDescription: String {
        switch self {
        case .healthApp:
            return "Health App"
        case .formula:
            return "Calculate"
        case .userEntered:
            return "Enter manually"
        }
    }
    
    var menuDescription: String {
        switch self {
        case .healthApp:
            return "Sync with Health App"
        case .formula:
            return "Calculate"
        case .userEntered:
            return "Enter manually"
        }
    }
    
    var systemImage: String {
        switch self {
        case .healthApp:
            return "heart.fill"
        case .formula:
            return "function"
        case .userEntered:
            return "keyboard"
        }
    }
}
