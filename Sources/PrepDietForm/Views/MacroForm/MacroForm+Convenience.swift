import Foundation

extension MacroForm {
    
    var workoutDuration: WorkoutDuration? {
        nil
    }
    
    var macroGoalType: MacroGoalType? {
        if goal.isForMeal {
            
            switch pickedMealMacroGoalType {
            case .fixed:
                return .fixed
            case .gramsPerWorkoutDuration:
                guard let workoutDuration else { return nil }
                return .gramsPerWorkoutDuration(workoutDuration)
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
