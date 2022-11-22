import SwiftUI
import SwiftUISugar
import SwiftHaptics

extension EnergyGoalForm {
    var body: some View {
        FormStyledScrollView {
            HStack(spacing: 0) {
                lowerBoundSection
                middleSection
                upperBoundSection
            }
            unitSection
                .padding(.bottom, 10)
            equivalentSection
        }
        .navigationTitle("Energy")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { trailingContent }
        .toolbar { bottomContents }
        .toolbar { keyboardContents }
        .onChange(of: pickedMealEnergyGoalType, perform: mealEnergyGoalChanged)
        .onChange(of: pickedDietEnergyGoalType, perform: dietEnergyGoalChanged)
        .onChange(of: pickedDelta, perform: deltaChanged)
        .onAppear(perform: appeared)
        .sheet(isPresented: $showingTDEEForm) { tdeeForm }
        .onDisappear(perform: disappeared)
        .scrollDismissesKeyboard(.interactively)
    }
    
    func disappeared() {
        goal.validateEnergy()
    }
    
    var bottomContents: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            deleteButton
        }
    }

    var keyboardContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
//            doneButton
            Spacer()
            deleteButton
        }
    }

    var trailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            dynamicIndicator
        }
    }
    
    var doneButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Done")
        }
    }
    
    @ViewBuilder
    var dynamicIndicator: some View {
        if isDynamic {
            appleHealthBolt
            Text("Dynamic")
                .font(.footnote)
                .textCase(.uppercase)
                .foregroundColor(Color(.tertiaryLabel))
        }
    }
    
    var deleteButton: some View {
        Button(role: .destructive) {
            Haptics.warningFeedback()
            didTapDelete(goal)
        } label: {
            Text("Delete")
                .foregroundColor(.red)
        }
    }
    
    var isDynamic: Bool {
        goal.isDynamic
    }
    
    @ViewBuilder
    var unitsFooter: some View {
        if isDynamic {
//            Text("Your maintenance energy will automatically adjust to changes from the Health App, making this a dynamic goal.")
            Text("Your maintenance energy is synced with the Health App, enabling this goal to automatically adjust to any changes.")
        }
    }
    
    var unitSection: some View {
        var horizontalScrollView: some View {
            FormStyledSection(footer: unitsFooter, horizontalPadding: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        typePicker
                        deltaPicker
                        tdeeButton
                    }
                    .padding(.horizontal, 17)
                }
                .frame(maxWidth: .infinity)
            }
        }
        
        var flowView: some View {
            FormStyledSection {
                FlowView(alignment: .leading, spacing: 10, padding: 37) {
                    typePicker
                    deltaPicker
                    tdeeButton
                }
            }
        }
        
        return Group {
            horizontalScrollView
//            flowView
        }
    }
    
    var tdeeForm: some View {
        TDEEForm(existingProfile: viewModel.bodyProfile, userUnits: .standard) { profile in
            viewModel.setBodyProfile(profile)
        }
    }
    
    @ViewBuilder
    var tdeeButton: some View {
        if shouldShowEnergyDeltaElements {
            Button {
                shouldResignFocus.toggle()
                Haptics.feedback(style: .soft)
                showingTDEEForm = true
            } label: {
                if let profile = viewModel.bodyProfile, let formattedTDEE = profile.formattedTDEEWithUnit {
                    if profile.parameters.hasDynamicTDEE {
                        PickerLabel(
                            formattedTDEE,
                            systemImage: "flame.fill",
                            imageColor: Color(hex: "F3DED7"),
                            backgroundGradientTop: Color(hex: AppleHealthTopColorHex),
                            backgroundGradientBottom: Color(hex: AppleHealthBottomColorHex),
                            foregroundColor: .white,
                            imageScale: .small
                        )
                    } else {
                        PickerLabel(
                            formattedTDEE,
                            systemImage: "flame.fill",
                            imageColor: Color(.tertiaryLabel),
                            imageScale: .small
                        )
                    }
                } else {
                    PickerLabel(
                        "set",
//                        prefix: "set",
                        systemImage: "flame.fill",
                        imageColor: Color.white.opacity(0.75),
                        backgroundColor: .accentColor,
                        foregroundColor: .white,
                        prefixColor: Color.white.opacity(0.75),
                        imageScale: .small
                    )
                }
            }
        }
    }
}

extension EnergyGoalForm {
    
    var lowerBoundSection: some View {
        let binding = Binding<Double?>(
            get: {
                return goal.lowerBound
            },
            set: { newValue in
                withAnimation {
                    goal.lowerBound = newValue
                }
            }
        )
        
        var header: some View {
            Text(goal.haveBothBounds ? "From" : "At least")
        }
        return FormStyledSection(header: header) {
            HStack {
                DoubleTextField(
                    double: binding,
                    placeholder: "Optional",
                    shouldResignFocus: $shouldResignFocus
                )
            }
        }
    }
    
    var upperBoundSection: some View {
        let binding = Binding<Double?>(
            get: { goal.upperBound },
            set: { newValue in
                withAnimation {
                    goal.upperBound = newValue
                }
            }
        )

        var header: some View {
            Text(goal.haveBothBounds ? "To" : "At most")
        }
        return FormStyledSection(header: header) {
            HStack {
                DoubleTextField(
                    double: binding,
                    placeholder: "Optional",
                    shouldResignFocus: $shouldResignFocus
                )
            }
        }
    }
    
    var middleSection: some View {
        VStack(spacing: 7) {
            Text("")
            if goal.lowerBound != nil, goal.upperBound == nil {
                Button {
                    Haptics.feedback(style: .rigid)
                    goal.upperBound = goal.lowerBound
                    goal.lowerBound = nil
                } label: {
//                    Image(systemName: "arrowshape.right.fill")
                    Image(systemName: "rectangle.righthalf.inset.filled.arrow.right")
                        .foregroundColor(.accentColor)
                }
            } else if goal.upperBound != nil, goal.lowerBound == nil {
                Button {
                    Haptics.feedback(style: .rigid)
                    goal.lowerBound = goal.upperBound
                    goal.upperBound = nil
                } label: {
//                    Image(systemName: "arrowshape.left.fill")
                    Image(systemName: "rectangle.lefthalf.inset.filled.arrow.left")
                        .foregroundColor(.accentColor)
                }
            }
//            else if goal.upperBound != nil, goal.lowerBound != nil {
//                Text("to")
//                    .font(.system(size: 17))
//                    .foregroundColor(Color(.tertiaryLabel))
//            }
        }
        .padding(.top, 10)
        .frame(width: 16, height: 20)
    }
    
    var unitView: some View {
        HStack {
            Text(goal.energyGoalType?.description ?? "")
                .foregroundColor(Color(.tertiaryLabel))
            if let difference = goal.energyGoalDelta {
                Spacer()
                Text(difference.description)
                    .foregroundColor(Color(.quaternaryLabel))
            }
        }
    }
    
    @ViewBuilder
    var footer: some View {
        EmptyView()
    }
    
    var equivalentSection: some View {
        @ViewBuilder
        var header: some View {
            if isDynamic {
                Text("Currently Equals")
            } else {
                Text("Equals")
            }
        }
        
        return Group {
            if goal.haveEquivalentValues {
                FormStyledSection(header: header) {
                    goal.equivalentTextHStack
                }
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

    static let proteinGoal = Goal(
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
