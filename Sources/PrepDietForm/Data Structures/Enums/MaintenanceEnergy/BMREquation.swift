import Foundation

public enum BMREquation: Int16, Hashable, Codable, CaseIterable {
    case harrisBenedict = 1
    case rozaShizgal
    case mifflinStJeor

    var description: String {
        switch self {
        case .harrisBenedict:
            return "Harris-Benedict"
        case .rozaShizgal:
            return "Roza-Shizgal"
        case .mifflinStJeor:
            return "Mifflin-St. Jeor"
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
        }
    }
}
