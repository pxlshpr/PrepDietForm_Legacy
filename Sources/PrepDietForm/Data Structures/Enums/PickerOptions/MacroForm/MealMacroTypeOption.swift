import Foundation

enum MealMacroTypeOption: CaseIterable {
    case fixed
    case gramsPerMinutesOfActivity
    
    init(goalViewModel: GoalViewModel) {
        self = .fixed
    }
    
    var menuDescription: String {
        switch self {
        case .fixed:
            return "grams"
        case .gramsPerMinutesOfActivity:
            return "grams / mins of exercise"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .fixed:
            return "g"
        case .gramsPerMinutesOfActivity:
            return "g / mins of exercise"
        }
    }
}
