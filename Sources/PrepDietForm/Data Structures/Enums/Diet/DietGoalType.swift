import SwiftUI
import PrepDataTypes

public enum DietGoalType: Hashable, Codable {
    case energy(DietEnergyGoalType)
    case macro(DietMacroGoalType, Macro)
    case micro(MicroGoalType, NutrientType, NutrientUnit)
}
