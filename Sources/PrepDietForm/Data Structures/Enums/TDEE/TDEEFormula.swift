import Foundation

public enum TDEEFormula: Int16, Hashable, Codable, CaseIterable {
    case harrisBenedict = 1
    case rozaShizgal
    case mifflinStJeor
    case katchMcardle

    var description: String {
        switch self {
        case .harrisBenedict:
            return "Harris-Benedict"
        case .rozaShizgal:
            return "Roza-Shizgal"
        case .mifflinStJeor:
            return "Mifflin-St. Jeor"
        case .katchMcardle:
            return "Katch-McArdle"
        }
    }
    
    var year: String {
        switch self {
        case .harrisBenedict:
            return "1919"
        case .rozaShizgal:
            return "1984"
        case .mifflinStJeor:
            return "1990"
        case .katchMcardle:
            return ""
        }
    }
}
