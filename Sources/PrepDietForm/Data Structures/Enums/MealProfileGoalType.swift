import SwiftUI
import PrepDataTypes

public enum MealProfileGoalType: Hashable, Codable {
    case energy(EnergyGoalUnit, EnergyDelta?)
    case macro(MacroGoalType, Macro)
    case micro(MicroGoalType, NutrientType, NutrientUnit)
}
