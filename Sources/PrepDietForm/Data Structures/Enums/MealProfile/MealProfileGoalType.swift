import SwiftUI
import PrepDataTypes

public enum MealProfileGoalType: Hashable, Codable {
    case energy(MealEnergyGoalType)
    case macro(MealMacroGoalType, Macro)
    case micro(MicroGoalType, NutrientType, NutrientUnit)
}
