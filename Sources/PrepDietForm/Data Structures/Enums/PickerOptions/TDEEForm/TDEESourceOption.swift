import Foundation

enum TDEESourceOption: CaseIterable {
    case healthKit
    case formula
    case userEntered
    
    var menuDescription: String {
        switch self {
        case .healthKit:
            return "Apple Health"
        case .formula:
            return "Formula"
        case .userEntered:
            return "Let me type it in"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .healthKit:
            return "Apple Health"
        case .formula:
            return "Formula"
        case .userEntered:
            return "Manual Entry"
        }
    }
    
    var systemImage: String {
        switch self {
        case .healthKit:
            return "heart.fill"
        case .formula:
            return "function"
        case .userEntered:
            return "keyboard"
        }
    }
}
