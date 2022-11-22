import SwiftUI
import PrepDataTypes

public class GoalSetViewModel: ObservableObject {
    
    @Published var name: String
    @Published var emoji: String
    @Published var goalViewModels: [GoalViewModel] = []
    @Published var isMealProfile = false
    
    /// Used to calculate equivalent values
    let userUnits: UserUnits
    @Published var bodyProfile: BodyProfile?
    
    @Published var nutrientTDEEFormViewModel: TDEEForm.ViewModel
    @Published var path: [GoalSetFormRoute] = []
    let existingGoalSet: GoalSet?
    
    init(
        userUnits: UserUnits,
        isMealProfile: Bool,
        existingGoalSet existing: GoalSet?,
        bodyProfile: BodyProfile? = nil,
        presentedGoalId: UUID? = nil
    ) {
        self.name = existing?.name ?? ""
        self.emoji = existing?.emoji ?? randomEmoji(forMealProfile: isMealProfile)
        self.isMealProfile = isMealProfile

        self.userUnits = userUnits
        self.bodyProfile = bodyProfile

        self.existingGoalSet = existing


        self.nutrientTDEEFormViewModel = TDEEForm.ViewModel(existingProfile: bodyProfile, userUnits: userUnits)

        self.goalViewModels = existing?.goals.goalViewModels(goalSet: self, isForMeal: isMealProfile) ?? []

        if let presentedGoalId, let goalViewModel = goalViewModels.first(where: { $0.id == presentedGoalId }) {
            self.path = [.goal(goalViewModel)]
        }
    }
}

extension GoalSetViewModel {
    
    func resetNutrientTDEEFormViewModel() {
        setNutrientTDEEFormViewModel(with: bodyProfile)
    }
    
    func setNutrientTDEEFormViewModel(with bodyProfile: BodyProfile?) {
        nutrientTDEEFormViewModel = TDEEForm.ViewModel(existingProfile: bodyProfile, userUnits: userUnits)
    }
    
    func setBodyProfile(_ bodyProfile: BodyProfile) {
        /// in addition to setting the current body Profile, we also update the view model (TDEEForm.ViewModel) we have  in GoalSetViewModel (or at least the relevant fields for weight and lbm)
        self.bodyProfile = bodyProfile
        setNutrientTDEEFormViewModel(with: bodyProfile)
    }
    
    func didAddNutrients(pickedEnergy: Bool, pickedMacros: [Macro], pickedMicros: [NutrientType]) {
        if pickedEnergy, !goalViewModels.containsEnergy {
            goalViewModels.append(GoalViewModel(
                goalSet: self,
                isForMeal: isMealProfile, type: .energy(.fixed(userUnits.energy))
            ))
        }
        for macro in pickedMacros {
            if !goalViewModels.containsMacro(macro) {
                goalViewModels.append(GoalViewModel(
                    goalSet: self,
                    isForMeal: isMealProfile,
                    type: .macro(.fixed, macro)
                ))
            }
        }
        for nutrientType in pickedMicros {
            if !goalViewModels.containsMicro(nutrientType) {
                goalViewModels.append(GoalViewModel(
                    goalSet: self,
                    isForMeal: isMealProfile,
                    type: .micro(.fixed, nutrientType, nutrientType.units.first ?? .g)
                ))
            }
        }
    }
    
    //MARK: - Convenience
    
    var containsGoalWithEquivalentValues: Bool {
        goalViewModels.contains(where: { $0.type.showsEquivalentValues })
    }
    
    func containsMacro(_ macro: Macro) -> Bool {
        goalViewModels.containsMacro(macro)
    }
    
    func containsMicro(_ micro: NutrientType) -> Bool {
        goalViewModels.containsMicro(micro)
    }
    
    var containsDynamicGoal: Bool {
        goalViewModels.contains(where: { $0.isDynamic })
    }
    
    var hasTDEE: Bool {
        bodyProfile?.hasTDEE ?? false
    }
    
    var hasWeight: Bool {
        bodyProfile?.hasWeight ?? false
    }
    var hasLBM: Bool {
        bodyProfile?.hasLBM ?? false
    }

    var energyGoal: GoalViewModel? {
        get {
            goalViewModels.first(where: { $0.type.isEnergy })
        }
        set {
            guard let newValue else {
                //TODO: maybe use this to remove it by setting it to nil?
                return
            }
            self.goalViewModels.update(with: newValue)
        }
    }
    
    var macroGoals: [GoalViewModel] {
        get {
            goalViewModels
                .filter({ $0.type.isMacro })
                .sorted(by: {
                    ($0.type.macro?.sortOrder ?? 0) < ($1.type.macro?.sortOrder ?? 0)
                })
        }
    }
    
    var microGoals: [GoalViewModel] {
        get {
            goalViewModels
                .filter({ $0.type.isMicro })
                .sorted(by: {
                    ($0.type.nutrientType?.rawValue ?? 0) < ($1.type.nutrientType?.rawValue ?? 0)
                })
        }
    }
}

extension Macro {
    var sortOrder: Int {
        switch self {
        case .carb:     return 1
        case .fat:      return 2
        case .protein:  return 3
        }
    }
}

let dietEmojis = "⤵️⤴️🍽️⚖️🏝🏋🏽🚴🏽🍩🍪🥛"
let mealProfileEmojis = "🤏🙌🏋🏽🚴🏽🍩🍪⚖️🥛"

func randomEmoji(forMealProfile: Bool) -> String {
    let array = forMealProfile ? mealProfileEmojis : dietEmojis
    guard let character = array.randomElement() else {
        return "⚖️"
    }
    return String(character)
}
