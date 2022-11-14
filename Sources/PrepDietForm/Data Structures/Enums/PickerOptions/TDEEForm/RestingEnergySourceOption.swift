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
            return "Formula"
        case .userEntered:
            return "Let me enter it"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .healthApp:
            return "Health App"
        case .formula:
            return "Formula"
        case .userEntered:
            return "Manual Entry"
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
