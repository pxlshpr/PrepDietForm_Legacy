import Foundation

enum ActiveEnergySourceOption: CaseIterable {
    case healthApp
    case activityLevel
    case userEntered
    
    var menuDescription: String {
        switch self {
        case .healthApp:
            return "Health App"
        case .activityLevel:
            return "Activity Level"
        case .userEntered:
            return "Let me enter it"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .healthApp:
            return "Health App"
        case .activityLevel:
            return "Activity Level"
        case .userEntered:
            return "Manual Entry"
        }
    }
    
    var systemImage: String {
        switch self {
        case .healthApp:
            return "heart.fill"
        case .activityLevel:
            return "figure.walk.motion"
        case .userEntered:
            return "keyboard"
        }
    }
}
