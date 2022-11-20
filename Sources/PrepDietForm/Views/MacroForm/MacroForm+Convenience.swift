import Foundation

extension MacroForm {
    
    var macroGoalType: MacroGoalType? {
        if goal.isForMeal {
            
            switch pickedMealMacroGoalType {
            case .fixed:
                return .fixed
            case .gramsPerWorkoutDuration:
                return .gramsPerWorkoutDuration(pickedWorkoutDurationUnit)
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
