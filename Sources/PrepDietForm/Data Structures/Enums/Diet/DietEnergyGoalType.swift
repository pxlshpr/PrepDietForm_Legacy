import Foundation
import PrepDataTypes

public enum DietEnergyGoalType: Hashable, Codable {
    case fixed(EnergyUnit)
    case fromMaintenance(EnergyUnit, EnergyDelta)
    case percentFromMaintenance(EnergyDelta)
}

public enum MealEnergyGoalType: Hashable, Codable {
    case fixed(EnergyUnit)
    case percentOfDietGoal
}

public enum MealMacroGoalType: Codable, Hashable {
    case fixed
    case gramsPerMinutesOfActivity
}

//case fixed(EnergyUnit)
//
///// Only used with Diets
//case fromMaintenace(EnergyUnit, EnergyDelta)
//case percentFromMaintenance(EnergyDelta)
//
///// Only used with Meal Profiles
//case percentOfDietGoal
