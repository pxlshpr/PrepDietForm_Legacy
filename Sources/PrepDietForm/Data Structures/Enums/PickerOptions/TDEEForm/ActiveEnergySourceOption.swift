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
            return "Activity level"
        case .userEntered:
            return "Enter manually"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .healthApp:
            return "Sync with Health App"
        case .activityLevel:
            return "Choose activity level"
        case .userEntered:
            return "Enter manually"
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
