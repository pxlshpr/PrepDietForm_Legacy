import Foundation

public enum RestingEnergyFormula: Int16, Hashable, Codable, CaseIterable {
    case katchMcardle = 1
    case henryOxford
    case mifflinStJeor
    case schofield
    case cunningham
    case rozaShizgal
    case harrisBenedict

    static var latest: [RestingEnergyFormula] {
        [.henryOxford, .katchMcardle, .mifflinStJeor, .schofield]
    }

    static var legacy: [RestingEnergyFormula] {
        [.rozaShizgal, .cunningham, .harrisBenedict]
    }

    var pickerDescription: String {
        switch self {
        case .schofield:
            return "Schofield (WHO)"
        case .henryOxford:
            return "Henry Oxford"
        case .harrisBenedict:
            return "Harris-Benedict"
        case .cunningham:
            return "Cunningham"
        case .rozaShizgal:
            return "Roza-Shizgal (Harris-Benedict Revised)"
        case .mifflinStJeor:
            return "Mifflin-St. Jeor"
        case .katchMcardle:
            return "Katch-McArdle"
        }
    }
    
    var menuDescription: String {
        switch self {
        case .schofield:
            return "Schofield"
        case .henryOxford:
            return "Oxford"
        case .harrisBenedict:
            return "Harris-Benedict"
        case .cunningham:
            return "Cunningham"
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
        case .schofield:
            return "1985"
        case .henryOxford:
            return "2005"
        case .harrisBenedict:
            return "1919"
        case .cunningham:
            return "1980"
        case .rozaShizgal:
            return "1984"
        case .mifflinStJeor:
            return "1990"
        case .katchMcardle:
            return "1996"
        }
    }
}
