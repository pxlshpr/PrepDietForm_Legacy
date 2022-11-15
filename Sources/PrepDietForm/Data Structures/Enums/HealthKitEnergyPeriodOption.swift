import Foundation

enum HealthKitEnergyPeriodOption: CaseIterable {
    case previousDay
    case average
    
    var menuDescription: String {
        switch self {
        case .previousDay:
            return "Previous Day"
        case .average:
            return "Daily Average"
        }
    }
    var pickerDescription: String {
        switch self {
        case .previousDay:
            return "Previous Day"
        case .average:
            return "Average of"
        }
    }
}
