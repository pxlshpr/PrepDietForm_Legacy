import SwiftUI
import SwiftUISugar
import PrepDataTypes
import SwiftHaptics

let EqualSymbol = "equal.square"

struct GoalCell: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var goal: GoalViewModel
    @Binding var showingEquivalentValues: Bool
    
    var body: some View {
        ZStack {
            content
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.bottom, 10)
    }
    
    var content: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                topRow
                bottomRow
            }
        }
    }
    
    var topRow: some View {
        HStack {
            Spacer().frame(width: 2)
            HStack(spacing: 4) {
                Image(systemName: goal.type.systemImage)
                    .font(.system(size: 14))
                Text(goal.type.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            Spacer()
            typeText
            if goal.isDynamic {
//                appleHealthSymbol
                appleHealthBolt
                    .imageScale(.small)
            }
            disclosureArrow
        }
        .foregroundColor(labelColor)
    }
    
    var shouldShowType: Bool {
        guard goal.hasOneBound else { return false }
//        if goal.equivalentLowerBound == nil && goal.equivalentUpperBound == nil {
//            return true
//        }
        guard !showingEquivalentValues else { return false }
        return goal.type.showsEquivalentValues
    }
    
    @ViewBuilder
    var typeText: some View {
        if shouldShowType,
           let string = goal.type.accessoryDescription,
           let icon = goal.type.accessorySystemImage
        {
            HStack {
                Image(systemName: icon)
                Text(string)
            }
            .foregroundColor(Color(.secondaryLabel))
            .font(.caption)
        }
    }
    
    var labelColor: Color {
        guard !isEmpty else {
            return Color(.secondaryLabel)
        }
        return goal.type.labelColor(for: colorScheme)
    }
    
    func amountText(_ double: Double) -> Text {
        Text("\(double.formattedGoalValue)")
            .foregroundColor(amountColor)
            .font(.system(size: isEmpty ? 20 : 28, weight: .medium, design: .rounded))
    }
    
    var isEmpty: Bool {
        goal.lowerBound == nil && goal.upperBound == nil
    }
    
    var amountColor: Color {
        isEmpty ? Color(.quaternaryLabel) : Color(.label)
    }

    func unitText(_ string: String) -> Text {
        Text(string)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .bold()
            .foregroundColor(Color(.secondaryLabel))
    }
    
    func amountAndUnitTexts(_ amount: Double, _ unit: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            amountText(amount)
                .multilineTextAlignment(.leading)
            if !isEmpty, let unit {
                unitText(unit)
            }
        }
    }
    
    func accessoryText(_ string: String) -> some View {
        Text(string)
            .font(.title3)
            .textCase(.lowercase)
            .foregroundColor(Color(.tertiaryLabel))
    }
    
    var bottomRow: some View {
        HStack {
            bottomRowTexts
            Spacer()
        }
        .frame(minHeight: 35)
    }
    
    var placeholderText: String? {
        guard let placeholderText = goal.placeholderText else {
            return nil
        }
        /// If the goal has at least one value
        if goal.hasOneBound {
            /// Only show the placeholder text (if available) when showing equivalent values
            guard showingEquivalentValues else {
                return nil
            }
        }
        
        return placeholderText
    }
    @ViewBuilder
    var bottomRowTexts: some View {
        if showingEquivalentValues {
            equivalentTexts
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .scale.combined(with: .opacity).combined(with: .move(edge: .bottom))
                ))
        } else {
            texts
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .scale.combined(with: .opacity).combined(with: .move(edge: .bottom))
                ))
        }
    }
    
    @ViewBuilder
    var texts: some View {
        if let placeholderText {
            Text(placeholderText)
                .foregroundColor(Color(.quaternaryLabel))
                .font(.system(size: 20, weight: .medium, design: .rounded))
        } else {
            HStack {
                if let lowerBound {
                    if upperBound == nil {
                        accessoryText("at least")
                    }
                    amountAndUnitTexts(lowerBound, upperBound == nil ? unitString : nil)
                }
                if let upperBound {
                    accessoryText(lowerBound == nil ? "below" : "to")
                    amountAndUnitTexts(upperBound, unitString)
                }
            }
        }
    }
    
    @ViewBuilder
    var equivalentTexts: some View {
        if let placeholderText {
            Text(placeholderText)
                .foregroundColor(Color(.quaternaryLabel))
                .font(.system(size: 20, weight: .medium, design: .rounded))
        } else {
            HStack {
                if showingEquivalentValues, goal.type.showsEquivalentValues {
                    Image(systemName: EqualSymbol)
                        .foregroundColor(Color(.tertiaryLabel))
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .scale.combined(with: .opacity).combined(with: .move(edge: .bottom))
                        ))
                }
                if let lowerBound {
                    if upperBound == nil {
                        accessoryText("at least")
                    }
                    amountAndUnitTexts(lowerBound, upperBound == nil ? unitString : nil)
                }
                if let upperBound {
                    accessoryText(lowerBound == nil ? "below" : "to")
                    amountAndUnitTexts(upperBound, unitString)
                }
            }
        }
    }
    
    var disclosureArrow: some View {
        Image(systemName: "chevron.forward")
            .font(.system(size: 14))
            .foregroundColor(Color(.tertiaryLabel))
            .fontWeight(.semibold)
    }
    
    var upperBound: Double? {
        if showingEquivalentValues, let upperBound = goal.equivalentUpperBound {
            return upperBound
        } else {
            return goal.upperBound
        }
    }
    
    var lowerBound: Double? {
        if showingEquivalentValues, let lowerBound = goal.equivalentLowerBound {
            return lowerBound
        } else {
            return goal.lowerBound
        }
    }
    
    var unitString: String {
        if showingEquivalentValues, let unitString = goal.equivalentUnitString {
            return unitString
        } else {
            return goal.type.unitString
        }
    }
}


//MARK: - 👁‍🗨 Previews

struct GoalSetForm_Previews: PreviewProvider {
    static var previews: some View {
        DietPreview()
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
            EnergyForm(goal: goalViewModel)
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
            MacroForm(goal: goal)
                .environmentObject(goalSet)
        }
    }
}

//MARK: - GoalSet Form Preview
public struct DietPreview: View {
    
    static let energyGoal = Goal(
        type: .energy(.fromMaintenance(.kcal, .surplus)),
        lowerBound: 500,
        upperBound: 750
    )
    
    static let fatGoalPerBodyMass = Goal(
        type: .macro(.gramsPerBodyMass(.leanMass, .kg), .fat),
        upperBound: 1
    )

    static let fatGoalPerEnergy = Goal(
        type: .macro(.percentageOfEnergy, .fat),
        upperBound: 20
    )

    static let proteinGoal = Goal(
        type: .macro(.gramsPerBodyMass(.weight, .kg), .protein),
        lowerBound: 1.1,
        upperBound: 2.5
    )

    static let goalSet = GoalSet(
        name: "Cutting",
        emoji: "🫃🏽",
        goals: [
            energyGoal,
            proteinGoal,
            fatGoalPerEnergy,
        ],
        isMealProfile: false
    )
    
    public init() { }
    
    public var body: some View {
        GoalSetForm(
            isMealProfile: false,
            existingGoalSet: Self.goalSet,
            bodyProfile: BodyProfile.mockBodyProfile
//            , presentedGoalId: Self.fatGoal.id
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
        type: .macro(.gramsPerWorkoutDuration(.min), .carb),
        lowerBound: 0.5
    )

    static let goalSet = GoalSet(
        name: "Pre-workout",
        emoji: "🏋🏽‍♂️",
        goals: [
            energyGoal,
            proteinGoal,
            carbGoal,
        ],
        isMealProfile: true
    )
    
    public init() { }
    
    public var body: some View {
        GoalSetForm(
            isMealProfile: true,
            existingGoalSet: Self.goalSet,
            bodyProfile: BodyProfile.mockBodyProfile
//            , presentedGoalId: Self.fatGoal.id
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
