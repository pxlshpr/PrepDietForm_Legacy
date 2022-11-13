import PrepDataTypes

extension WeightUnit {
    var menuDescription: String {
        switch self {
        case .kg:
            return "kilogram"
        case .lb:
            return "pound"
        default:
            return "unsupported"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .kg:
            return "kilogram"
        case .lb:
            return "pound"
        default:
            return "unsupported"
        }
    }
    
    var pickerPrefix: String {
        "per "
    }
}
