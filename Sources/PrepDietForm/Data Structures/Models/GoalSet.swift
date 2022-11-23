import Foundation
import PrepDataTypes

public struct GoalSet: Identifiable, Hashable, Codable {
    
    public let id: UUID

    public var name: String
    public var emoji: String
    public var goals: [Goal] = []
    public var isMealProfile: Bool

    public let isPreset: Bool

    public var syncStatus: SyncStatus
    public var updatedAt: Double
    public var deletedAt: Double?
    
    public init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        goals: [Goal] = [],
        isMealProfile: Bool = false,
        isPreset: Bool = false,
        syncStatus: SyncStatus = .notSynced,
        updatedAt: Double = Date().timeIntervalSinceNow,
        deletedAt: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.goals = goals
        self.isMealProfile = isMealProfile
        self.isPreset = isPreset
        self.syncStatus = syncStatus
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension GoalSet {
    var energyGoal: Goal? {
        goals.first(where: { $0.type.isEnergy })
    }
    
    /// Creates an auto energy goal if we have goals for all 3 macros
    func autoEnergyGoal(with params: GoalCalcParams) -> Goal? {
        calculateMissingGoal(
            energy: nil,
            carb: carbGoal,
            fat: fatGoal,
            protein: proteinGoal,
            with: params
        )
    }
    
    var carbGoal: Goal? { goals.first(where: { $0.type.macro == .carb }) }
    var fatGoal: Goal? { goals.first(where: { $0.type.macro == .fat }) }
    var proteinGoal: Goal? { goals.first(where: { $0.type.macro == .protein }) }
}

struct GoalCalcParams {
    let userUnits: UserUnits
    let bodyProfile: BodyProfile?
    let energyGoal: Goal?
}

func calculateMissingGoal(
    energy: Goal?,
    carb: Goal?,
    fat: Goal?,
    protein: Goal?,
    with params: GoalCalcParams
) -> Goal? {
    if energy == nil {
        /// Calculate energy
        guard let carb, let fat, let protein else { return nil }
        guard let carbLower = carb.lowerOrUpper(with: params),
              let carbUpper = carb.upperOrLower(with: params),
              let fatLower = fat.lowerOrUpper(with: params),
              let fatUpper = fat.upperOrLower(with: params),
              let proteinLower = protein.lowerOrUpper(with: params),
              let proteinUpper = protein.upperOrLower(with: params)
        else { return nil }
        
        let lower = calculateEnergy(c: carbLower, f: fatLower, p: proteinLower)
        let upper = calculateEnergy(c: carbUpper, f: fatUpper, p: proteinUpper)

        var pickedLower: Double? = lower
        var pickedUpper: Double? = upper
        /// If we've got only one value (implying that none of the macros have both bounds)
        if lower.rounded(toPlaces: 2) == upper.rounded(toPlaces: 2) {
            /// Keep the side that's prevalent amongst the macros
            if [carb, fat, protein].isPredominantlyLowerBounded {
                pickedUpper = nil
            } else {
                pickedLower = nil
            }
            
        }
        
        let goal = Goal(
            type: .energy(.fixed(params.userUnits.energy)),
            lowerBound: pickedLower,
            upperBound: pickedUpper
        )
        
        return goal
    }
    return nil
}

func calculateEnergy(c: Double, f: Double, p: Double) -> Double {
    (c * KcalsPerGramOfCarb) + (f * KcalsPerGramOfFat) + (p * KcalsPerGramOfProtein)
}

extension Goal {
    var hasOneBoundOnly: Bool {
        hasLowerBoundOnly || hasUpperBoundOnly
    }
    var hasLowerBoundOnly: Bool {
        lowerBound != nil && upperBound == nil
    }
    
    var hasUpperBoundOnly: Bool {
        upperBound != nil && lowerBound == nil
    }
}
extension Array where Element == Goal {
    
    /// returns true if the number of goals with lower bounds are greater than half of the total count with only one bound
    var isPredominantlyLowerBounded: Bool {
        let singleBoundedCount = filter({ $0.hasOneBoundOnly }).count
        let lowerBoundedCount = filter({ $0.hasLowerBoundOnly }).count
        guard singleBoundedCount > 0 else { return false }
        return (Double(lowerBoundedCount) / Double(singleBoundedCount)) > 0.5
    }
}

import SwiftUI

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
    
    @StateObject var viewModel: GoalSetViewModel
    @StateObject var goalViewModel: GoalViewModel
    
    init() {
        let goalSetViewModel = GoalSetViewModel(
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
            EnergyGoalForm(goal: goalViewModel, didTapDelete: { _ in
                
            })
                .environmentObject(viewModel)
        }
    }
}

//MARK: Macro Form

struct MacroFormPreview: View {
    
    @StateObject var goalSet: GoalSetViewModel
    @StateObject var goal: GoalViewModel
    
    init() {
        let goalSet = GoalSetViewModel(
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
            NutrientGoalForm(goal: goal, didTapDelete: { _ in
                
            })
                .environmentObject(goalSet)
        }
    }
}

//MARK: - GoalSet Form Preview
public struct DietPreview: View {
    
    static let energyGoal = Goal(
        type: .energy(.fromMaintenance(.kcal, .deficit))
        , lowerBound: 500
        , upperBound: 750
    )
    
    static let fatGoalPerBodyMass = Goal(
        type: .macro(.quantityPerBodyMass(.leanMass, .kg), .fat),
        upperBound: 1
    )

    static let fatGoalPerEnergy = Goal(
        type: .macro(.percentageOfEnergy, .fat),
        upperBound: 20
    )

    static let fatGoalFixed = Goal(
        type: .macro(.fixed, .fat),
        upperBound: 60
    )

    static let carbGoalFixed = Goal(
        type: .macro(.fixed, .carb),
        upperBound: 200
    )

    static let proteinGoalFixed = Goal(
        type: .macro(.fixed, .protein),
        lowerBound: 180
    )

    static let proteinGoalPerBodyMass = Goal(
        type: .macro(.quantityPerBodyMass(.weight, .kg), .protein),
        lowerBound: 1.1,
        upperBound: 2.5
    )

    static let magnesiumGoal = Goal(
        type: .micro(.fixed, .magnesium, .mg),
        lowerBound: 400
    )

    static let sugarGoal = Goal(
        type: .micro(.percentageOfEnergy, .sugars, .g),
        upperBound: 10
    )

    static let goalSet = GoalSet(
        name: "Cutting",
        emoji: "🫃🏽",
        goals: [
//            energyGoal,
//            proteinGoalPerBodyMass,
            proteinGoalFixed,
//            fatGoalPerEnergy,
//            fatGoalPerBodyMass,
            fatGoalFixed,
            carbGoalFixed,
//            magnesiumGoal,
//            sugarGoal
        ],
        isMealProfile: false
    )
    
    public init() { }
    
    public var body: some View {
        GoalSetForm(
            isMealProfile: false,
            existingGoalSet: Self.goalSet,
            bodyProfile: BodyProfile.mockBodyProfile
//            , presentedGoalId: Self.energyGoal.id
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
        type: .micro(.quantityPerWorkoutDuration(.hour), .sodium, .mg),
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
