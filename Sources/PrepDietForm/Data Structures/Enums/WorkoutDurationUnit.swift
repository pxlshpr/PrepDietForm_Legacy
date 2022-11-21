import Foundation

public enum WorkoutDurationUnit: Int16, Codable, CaseIterable {
    case min = 1
    case hour
    
    var pickerDescription: String {
        switch self {
        case .min:
            return "minute"
        case .hour:
            return "hour"
        }
    }
    
    var menuDescription: String {
        switch self {
        case .min:
            return "minute"
        case .hour:
            return "hour"
        }
    }
}
