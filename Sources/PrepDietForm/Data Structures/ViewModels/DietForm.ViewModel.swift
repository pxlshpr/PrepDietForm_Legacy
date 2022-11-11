import SwiftUI
import PrepDataTypes

extension DietForm {
    class ViewModel: ObservableObject {
        @Published var name = "New Diet"
        @Published var goals: [GoalViewModel] = []
    }
}

extension DietForm.ViewModel {
    func containsMacro(_ macro: Macro) -> Bool {
        goals.containsMacro(macro)
    }
    
    func containsMicro(_ micro: NutrientType) -> Bool {
        goals.containsMicro(micro)
    }
    
    func didAddNutrients(pickedEnergy: Bool, pickedMacros: [Macro], pickedMicros: [NutrientType]) {
        if pickedEnergy, !goals.containsEnergy {
            goals.append(.init(type: .energy(.kcal, nil)))
        }
        for macro in pickedMacros {
            if !goals.containsMacro(macro) {
                goals.append(.init(type:.macro(.fixed, macro)))
            }
        }
        for nutrientType in pickedMicros {
            if !goals.containsMicro(nutrientType) {
                goals.append(.init(type: .micro(.fixed, nutrientType, nutrientType.units.first ?? .g)))
            }
        }
    }
    
    var energyGoal: GoalViewModel {
        get {
            guard let energyGoal = goals.first(where: { $0.type.isEnergy }) else {
                let newGoal = GoalViewModel(type: .energy(.kcal, nil))
                goals.append(newGoal)
                return newGoal
            }
            return energyGoal
        }
        set {
            self.goals.update(with: newValue)
        }
    }
}
