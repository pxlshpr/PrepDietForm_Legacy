import Foundation

enum HealthPeriodOption: CaseIterable {
    case previousDay
    case average
    
    var pickerDescription: String {
        switch self {
        case .previousDay:
            return "Previous Day"
        case .average:
            return "Daily Average"
        }
    }
    var menuDescription: String {
        switch self {
        case .previousDay:
            return "previous day's value"
        case .average:
            return "daily average of"
        }
    }
    
    var energyPrefix: String {
        switch self {
        case .previousDay:
            return "yesterday"
        case .average:
            return "currently"
        }
    }
}
