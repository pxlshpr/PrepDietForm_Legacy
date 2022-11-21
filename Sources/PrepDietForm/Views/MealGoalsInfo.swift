import SwiftUI
import SwiftUISugar

struct MealTypesInfo: View {
    var body: some View {
        FormStyledScrollView {
            FormStyledSection(header: Text("What are they?")) {
                VStack(alignment: .leading) {
                    Text("Meal Types are similar to Diets, in that they have their own sets of goals, but apply to a single meal as opposed to the entire day.")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            FormStyledSection(header: Text("Why use them?")) {
                VStack(alignment: .leading) {
                    Text("They are useful for meals you might have specific goals for.")
                        .fixedSize(horizontal: false, vertical: true)
                    Divider().opacity(0)
                    Text("Since meals automatically get assigned equally distributed goals from your diet, there may be instances where you would like to override them with your own custom goals.")
                        .fixedSize(horizontal: false, vertical: true)
                    Divider().padding(.vertical)
                    Text("For example, you could have a **\"Pre-Workout\"** Meal Type, and set a carbohyrate goal for it.")
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(.secondaryLabel))
                    Divider().opacity(0)
                    Text("This will display as your carb goal for that meal, regardless of the diet you've picked for that day.")
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(.secondaryLabel))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Meal Types")
//        .navigationBarTitleDisplayMode(.inline)
    }
}
struct MealGoalsInfo: View {
    
    var body: some View {
        NavigationView {
            FormStyledScrollView {
                FormStyledSection(header: Text("What are they?")) {
                    VStack(alignment: .leading) {
                        Text("When you select a diet, all of its goals are *equally* distributed across your **unplanned** meals for the day.")
                            .fixedSize(horizontal: false, vertical: true)
                        Divider().opacity(0)
                        Text("This creates subgoals for each meal that you can use as a guideline when prepping foods.")
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                FormStyledSection(header: Text("Disabling Micronutrients")) {
                    VStack(alignment: .leading) {
                        Text("These subgoals can be disabled for micronutrients that you do not plan on spreading out across your meals.")
                            .fixedSize(horizontal: false, vertical: true)
                        Divider().opacity(0)
                        Text("For example, you may decide to disable this for your magnesium goal if you plan on taking a supplement for it and completing your goal in one go.")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                FormStyledSection(header: mealTypesHeader) {
                    VStack(alignment: .leading) {
                        Text("If you have **Meal Types** assigned to any meals, their goals will be used *instead of* these subgoals.")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                FormStyledSection(header: Text("Planned meals")) {
                    VStack(alignment: .leading) {
                        Text("Once a meal has been planned by prepping foods for it, the subgoals for any remaining **unplanned** meals will adjust to what's left of your diet's goal.")
                            .fixedSize(horizontal: false, vertical: true)
                        Divider().opacity(0)
                        Text("In other words, these subgoals will always be an equal distribution of your remaining diet goal for each nutrient—after *subtracting* values from **planned** meals and goals of **Meal Types** you may have chosen.")
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("Meal Goals")
//            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var mealTypesHeader: some View {
        HStack {
            Text("Using with Meal Types")
            Spacer()
            NavigationLink {
                MealTypesInfo()
            } label: {
                HStack {
                    Text("Learn More")
                        .textCase(.none)
                    Image(systemName: "info.circle")
                }
                .foregroundColor(.accentColor)
            }
        }
    }
}

//MARK: - 👁‍🗨 Previews

struct DietForm_Previews: PreviewProvider {
    static var previews: some View {
        DietPreview()
    }
}

struct MealTypeForm_Previews: PreviewProvider {
    static var previews: some View {
        MealTypePreview()
    }
}


struct EnergyForm_Previews: PreviewProvider {
    
    static var previews: some View {
        EnergyFormPreview()
    }
}

struct MacroForm_Previews: PreviewProvider {
    
    static var previews: some View {
        MacroFormPreview()
    }
}


//MARK: Energy Form Preview

struct EnergyFormPreview: View {
    
    @StateObject var viewModel: GoalSetForm.ViewModel
    @StateObject var goalViewModel: GoalViewModel
    
    init() {
        let goalSetViewModel = GoalSetForm.ViewModel(
            userUnits:.standard,
            isMealProfile: false,
            existingGoalSet: nil,
            bodyProfile: BodyProfile(
                id: UUID(),
                parameters: .init(energyUnit: .kcal, weightUnit: .kg, heightUnit: .cm, restingEnergy: 2000, restingEnergySource: .userEntered, activeEnergy: 1100, activeEnergySource: .userEntered),
                syncStatus: .notSynced,
                updatedAt: Date().timeIntervalSince1970
            )
        )
        let goalViewModel = GoalViewModel(
            goalSet: goalSetViewModel,
            isForMeal: false,
            type: .energy(.fromMaintenance(.kcal, .deficit)),
            lowerBound: 500
//            , upperBound: 750
        )
        _viewModel = StateObject(wrappedValue: goalSetViewModel)
        _goalViewModel = StateObject(wrappedValue: goalViewModel)
    }
    
    var body: some View {
        NavigationView {
            EnergyForm(goal: goalViewModel, didTapDelete: { _ in
                
            })
                .environmentObject(viewModel)
        }
    }
}

//MARK: Macro Form

struct MacroFormPreview: View {
    
    @StateObject var goalSet: GoalSetForm.ViewModel
    @StateObject var goal: GoalViewModel
    
    init() {
        let goalSet = GoalSetForm.ViewModel(
            userUnits: .standard,
            isMealProfile: false,
            existingGoalSet: GoalSet(
                name: "Bulking",
                emoji: "",
                goals: [
                    Goal(type: .energy(.fromMaintenance(.kcal, .surplus)), lowerBound: 500, upperBound: 1500)
                ]
            ),
            bodyProfile: .mock(
                restingEnergy: 1000,
                lbm: 77
            )
        )
        let goal = GoalViewModel(
            goalSet: goalSet,
            isForMeal: false,
            type: .macro(.percentageOfEnergy, .carb),
            lowerBound: 20,
            upperBound: 30
        )
        _goalSet = StateObject(wrappedValue: goalSet)
        _goal = StateObject(wrappedValue: goal)
    }
    
    var body: some View {
        NavigationView {
            NutrientForm(goal: goal, didTapDelete: { _ in
                
            })
                .environmentObject(goalSet)
        }
    }
}

//MARK: - GoalSet Form Preview
public struct DietPreview: View {
    
    static let energyGoal = Goal(
        type: .energy(.fromMaintenance(.kcal, .deficit)),
        lowerBound: 500,
        upperBound: 750
    )
    
    static let fatGoalPerBodyMass = Goal(
        type: .macro(.quantityPerBodyMass(.leanMass, .kg), .fat),
        upperBound: 1
    )

    static let fatGoalPerEnergy = Goal(
        type: .macro(.percentageOfEnergy, .fat),
        upperBound: 20
    )

    static let proteinGoal = Goal(
        type: .macro(.quantityPerBodyMass(.weight, .kg), .protein),
        lowerBound: 1.1,
        upperBound: 2.5
    )

    static let magnesiumGoal = Goal(
        type: .micro(.fixed, .magnesium, .mg, false),
        lowerBound: 400
    )

    static let sugarGoal = Goal(
        type: .micro(.fixed, .sugars, .g, true),
        upperBound: 80
    )

    static let goalSet = GoalSet(
        name: "Cutting",
        emoji: "🫃🏽",
        goals: [
            energyGoal,
//            proteinGoal,
//            fatGoalPerEnergy,
            magnesiumGoal,
            sugarGoal
        ],
        isMealProfile: false
    )
    
    public init() { }
    
    public var body: some View {
        GoalSetForm(
            isMealProfile: false,
            existingGoalSet: Self.goalSet,
            bodyProfile: BodyProfile.mockBodyProfile
//            , presentedGoalId: Self.sugarGoal.id
        )
    }
}

public struct MealTypePreview: View {
    
    static let energyGoal = Goal(
        type: .energy(.fixed(.kcal)),
        lowerBound: 250,
        upperBound: 350
    )
    
    static let proteinGoal = Goal(
        type: .macro(.fixed, .protein),
        lowerBound: 20
    )

    static let carbGoal = Goal(
        type: .macro(.quantityPerWorkoutDuration(.min), .carb),
        lowerBound: 0.5
    )

    static let sodiumGoal = Goal(
        type: .micro(.quantityPerWorkoutDuration(.hour), .sodium, .mg, true),
        lowerBound: 300,
        upperBound: 600
    )

    static let goalSet = GoalSet(
        name: "Workout Fuel",
        emoji: "🚴🏽",
        goals: [
            energyGoal,
//            proteinGoal,
//            carbGoal,
            sodiumGoal
        ],
        isMealProfile: true
    )
    
    public init() { }
    
    public var body: some View {
        GoalSetForm(
            isMealProfile: true,
            existingGoalSet: Self.goalSet,
            bodyProfile: BodyProfile.mockBodyProfile
//            , presentedGoalId: Self.sodiumGoal.id
        )
    }
}

extension BodyProfile {
    static let mockBodyProfile = BodyProfile.mock(
        restingEnergy: 2000,
        activeEnergy: 1000,
        weight: 98,
        lbm: 65
    )
}
