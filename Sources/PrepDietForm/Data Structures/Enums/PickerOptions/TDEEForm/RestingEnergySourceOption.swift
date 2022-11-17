import Foundation

enum RestingEnergySourceOption: CaseIterable {
    case healthApp
    case formula
    case userEntered
    
    var menuDescription: String {
        switch self {
        case .healthApp:
            return "Health App"
        case .formula:
            return "Calculate"
        case .userEntered:
            return "Enter Manually"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .healthApp:
            return "Health App"
        case .formula:
            return "Calculate"
        case .userEntered:
            return "Enter Manually"
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
