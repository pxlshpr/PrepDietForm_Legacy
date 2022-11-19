import Foundation

extension MacroForm {
    
    var minutesOfActivity: Double {
        60
    }
    
    var macroGoalType: MacroGoalType? {
        if goal.isForMeal {
            
            switch pickedMealMacroGoalType {
            case .fixed:
                return .fixed
            case .gramsPerMinutesOfActivity:
                return .gramsPerMinutesOfActivity(minutesOfActivity)
            }
            
        } else {
            switch pickedDietMacroGoalType {
            case .fixed:
                return .fixed
            case .gramsPerBodyMass:
                return .gramsPerBodyMass(pickedBodyMassType, pickedBodyMassUnit)
            case .percentageOfEnergy:
                return .percentageOfEnergy
            }
        }
    }
}
