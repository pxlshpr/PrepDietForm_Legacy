import Foundation

extension MacroForm {
    
    var macroGoalType: NutrientGoalType? {
        if goal.isForMeal {
            
            switch pickedMealMacroGoalType {
            case .fixed:
                return .fixed
            case .gramsPerWorkoutDuration:
                return .quantityPerWorkoutDuration(pickedWorkoutDurationUnit)
            }
            
        } else {
            switch pickedDietMacroGoalType {
            case .fixed:
                return .fixed
            case .gramsPerBodyMass:
                return .quantityPerBodyMass(pickedBodyMassType, pickedBodyMassUnit)
            case .percentageOfEnergy:
                return .percentageOfEnergy
            }
        }
    }
}
