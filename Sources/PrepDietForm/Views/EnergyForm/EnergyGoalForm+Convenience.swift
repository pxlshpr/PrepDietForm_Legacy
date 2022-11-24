import Foundation
import PrepDataTypes

extension EnergyGoalForm {
    
    var energyUnit: EnergyUnit {
        goal.energyUnit ?? .kcal
    }
    
    var energyDelta: EnergyGoalDelta {
        switch pickedDelta {
        case .below:
            return .deficit
        case .above:
            return .surplus
        }
    }
    
    var energyGoalType: EnergyGoalType? {
        if goal.isForMeal {
            switch pickedMealEnergyGoalType {
            case .fixed:
                return .fixed(energyUnit)
            }
        } else {
            switch pickedDietEnergyGoalType {
            case .fixed:
                return .fixed(energyUnit)
            case .fromMaintenance:
                return .fromMaintenance(energyUnit, energyDelta)
            case .percentageFromMaintenance:
                return .percentFromMaintenance(energyDelta)
            }
        }
    }
    
    var shouldShowEnergyDeltaElements: Bool {
        !goal.isForMeal && pickedDietEnergyGoalType != .fixed
    }
}
