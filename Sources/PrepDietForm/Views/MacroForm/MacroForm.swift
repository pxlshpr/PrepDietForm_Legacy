import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes

struct MacroForm: View {
    
    @EnvironmentObject var goalSet: GoalSetForm.ViewModel
    @ObservedObject var goal: GoalViewModel
    
    @State var pickedMealMacroGoalType: MealMacroTypeOption
    @State var pickedDietMacroGoalType: DietMacroTypeOption
    @State var pickedBodyMassType: MacroGoalType.BodyMass
    @State var pickedBodyMassUnit: WeightUnit
    
    @State var pickedWorkoutDurationUnit: WorkoutDurationUnit
    
    @State var showingLeanMassForm: Bool = false
    @State var showingWeightForm: Bool = false
    
    @State var shouldResignFocus = false
    
    init(goal: GoalViewModel) {
        self.goal = goal
        let pickedMealMacroGoalType = MealMacroTypeOption(goalViewModel: goal) ?? .fixed
        let pickedDietMacroGoalType = DietMacroTypeOption(goalViewModel: goal) ?? .fixed
        let bodyMassType = goal.bodyMassType ?? .weight
        let bodyMassUnit = goal.bodyMassUnit ?? .kg // TODO: User's default unit here
        let workoutDurationUnit = goal.workoutDurationUnit ?? .min
        _pickedMealMacroGoalType = State(initialValue: pickedMealMacroGoalType)
        _pickedDietMacroGoalType = State(initialValue: pickedDietMacroGoalType)
        _pickedBodyMassType = State(initialValue: bodyMassType)
        _pickedBodyMassUnit = State(initialValue: bodyMassUnit)
        _pickedWorkoutDurationUnit = State(initialValue: workoutDurationUnit)
    }
}

extension MacroForm {
    
    var body: some View {
        FormStyledScrollView {
            HStack(spacing: 0) {
                lowerBoundSection
                swapValuesButton
                upperBoundSection
            }
            unitSection
            bodyMassSection
            equivalentSection
        }
        .navigationTitle("\(goal.macro?.description ?? "Macro")")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { trailingContent }
        .sheet(isPresented: $showingWeightForm) { weightForm }
        .sheet(isPresented: $showingLeanMassForm) { leanMassForm }
        .onDisappear(perform: goal.validateMacro)
    }
    
    //MARK: - Sections
    
    
    var unitSection: some View {
        FormStyledSection(footer: unitsFooter, horizontalPadding: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    typePicker
                    bodyMassUnitPicker
                    bodyMassTypePicker
                    workoutDurationUnitPicker
                    Spacer()
                }
                .padding(.horizontal, 17)
            }
            .frame(maxWidth: .infinity)
//            .frame(height: 50)
        }
    }
    
    var lowerBoundSection: some View {
        let binding = Binding<Double?>(
            get: { goal.lowerBound },
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
    
    //MARK: - Decorator Views
    
    var trailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if isDynamic {
                Text("Dynamic")
                    .font(.footnote)
                    .textCase(.uppercase)
                    .foregroundColor(Color(.tertiaryLabel))
                appleHealthBolt
            }
        }
    }

    var unitsFooter: some View {
        var component: String {
            switch macroGoalType {
            case .gramsPerBodyMass(let bodyMass, _):
                return bodyMass.description
            case .percentageOfEnergy:
                return "maintenance energy (which your energy goal is based on)"
            default:
                return ""
            }
        }
        return Group {
            if isDynamic {
                Text("Your \(component) is synced with the Health App. This goal will automatically adjust when it changes.")
            } else {
                switch macroGoalType {
                case .fixed:
                    EmptyView()
                case .percentageOfEnergy:
                    Text("Your energy goal is being used to calculate this goal.")
                case .gramsPerBodyMass:
                    EmptyView()
                case .gramsPerWorkoutDuration(_):
                    Text("Your planned workout duration will be used to calculate this goal. You can specify it when creating a meal with this type.")
                    /**
                     Text("Use this when you want to create a dynamic goal based on how long you workout for.")
                     Text("For e.g., you could create an \"intra-workout\" meal type that has a 0.5g/min carb goal.")
                     Text("You can then set or use your last workout time when creating a meal with this type.")
                     */
                default:
                    EmptyView()
                }
            }
        }
    }
    
    //MARK: - Forms
    
    var weightForm: some View {
        MacroWeightForm(existingProfile: goalSet.bodyProfile, didTapSave: { bodyProfile in
            goalSet.setBodyProfile(bodyProfile)
        }, didTapClose: {
            goalSet.resetMacroTDEEFormViewModel()
        })
        .environmentObject(goalSet.macroTDEEFormViewModel)
    }
    
    var leanMassForm: some View {
        MacroLeanBodyMassForm(existingProfile: goalSet.bodyProfile, didTapSave: { bodyProfile in
            goalSet.setBodyProfile(bodyProfile)
        }, didTapClose: {
            goalSet.resetMacroTDEEFormViewModel()
        })
        .environmentObject(goalSet.macroTDEEFormViewModel)
    }
    
    @ViewBuilder
    var bodyMassSection: some View {
        
        var footer: some View {
            Text("Your \(pickedBodyMassType.description) is being used to calculate this goal.")
        }
        return Group {
            if pickedDietMacroGoalType == .gramsPerBodyMass {
                FormStyledSection(header: Text("with"), footer: footer) {
                    HStack {
                        bodyMassButton
                        Spacer()
                    }
                }
            }
        }
    }
    
    //MARK: - Convenience

    var haveBodyMass: Bool {
        switch pickedBodyMassType {
        case .weight:
            return goalSet.bodyProfile?.hasWeight == true
        case .leanMass:
            return goalSet.bodyProfile?.hasLBM == true
        }
    }
    
    var isDynamic: Bool {
        goal.isDynamic
    }

    var bodyMassFormattedWithUnit: String {
        guard let params = goalSet.bodyProfile?.parameters else { return "" }
        switch pickedBodyMassType {
        case .weight:
            guard let weight = params.weight else { return "" }
            return weight.rounded(toPlaces: 1).cleanAmount + " \(params.weightUnit.shortDescription)"
        case .leanMass:
            guard let lbm = params.lbm else { return "" }
            return lbm.rounded(toPlaces: 1).cleanAmount + " \(params.weightUnit.shortDescription)"
        }
    }
    
    //MARK: - Buttons
    
    @ViewBuilder
    var bodyMassButton: some View {
        Button {
            shouldResignFocus.toggle()
            switch pickedBodyMassType {
            case .weight:
                showingWeightForm = true
            case .leanMass:
                showingLeanMassForm = true
            }
        } label: {
            if haveBodyMass {
                if goal.bodyMassIsSyncedWithHealth {
                    PickerLabel(
                        bodyMassFormattedWithUnit,
                        prefix: "\(pickedBodyMassType.description)",
                        systemImage: "figure.arms.open",
                        imageColor: Color(hex: "F3DED7"),
                        backgroundGradientTop: Color(hex: AppleHealthTopColorHex),
                        backgroundGradientBottom: Color(hex: AppleHealthBottomColorHex),
                        foregroundColor: .white,
                        prefixColor: Color(hex: "F3DED7"),
                        imageScale: .medium
                    )
                } else {
                    PickerLabel(
                        bodyMassFormattedWithUnit,
                        prefix: "\(pickedBodyMassType.description)",
                        systemImage: "figure.arms.open",
                        imageColor: Color(.tertiaryLabel),
                        imageScale: .medium
                    )
                }
            } else {
                PickerLabel(
                    "\(pickedBodyMassType.description)",
                    prefix: "set",
                    systemImage: "figure.arms.open",
                    imageColor: Color.white.opacity(0.75),
                    backgroundColor: .accentColor,
                    foregroundColor: .white,
                    prefixColor: Color.white.opacity(0.75),
                    imageScale: .medium
                )
            }
        }
    }

    var swapValuesButton: some View {
        VStack(spacing: 7) {
            Text("")
            if goal.lowerBound != nil, goal.upperBound == nil {
                Button {
                    Haptics.feedback(style: .rigid)
                    goal.upperBound = goal.lowerBound
                    goal.lowerBound = nil
                } label: {
                    Image(systemName: "rectangle.righthalf.inset.filled.arrow.right")
                        .foregroundColor(.accentColor)
                }
            } else if goal.upperBound != nil, goal.lowerBound == nil {
                Button {
                    Haptics.feedback(style: .rigid)
                    goal.lowerBound = goal.upperBound
                    goal.upperBound = nil
                } label: {
                    Image(systemName: "rectangle.lefthalf.inset.filled.arrow.left")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding(.top, 10)
        .frame(width: 16, height: 20)
    }
    
    //MARK: - Pickers
    
    @ViewBuilder
    var typePicker: some View {
        if goal.isForMeal {
            mealTypePicker
        } else {
            dietTypePicker
        }
    }
    
    var mealTypePicker: some View {
        let binding = Binding<MealMacroTypeOption>(
            get: { pickedMealMacroGoalType },
            set: { newType in
                withAnimation {
                    self.pickedMealMacroGoalType = newType
                }
                self.goal.macroGoalType = macroGoalType
            }
        )
        return Menu {
            Picker(selection: binding, label: EmptyView()) {
                ForEach(MealMacroTypeOption.allCases, id: \.self) {
                    Text($0.menuDescription).tag($0)
                }
            }
        } label: {
            PickerLabel(pickedMealMacroGoalType.pickerDescription)
        }
        .animation(.none, value: pickedMealMacroGoalType)
        .simultaneousGesture(TapGesture().onEnded {
            Haptics.feedback(style: .soft)
        })
    }
    
    var dietTypePicker: some View {
        let binding = Binding<DietMacroTypeOption>(
            get: { pickedDietMacroGoalType },
            set: { newType in
                withAnimation {
                    self.pickedDietMacroGoalType = newType
                }
                self.goal.macroGoalType = macroGoalType
            }
        )
        
        return Menu {
            Picker(selection: binding, label: EmptyView()) {
                ForEach(DietMacroTypeOption.allCases, id: \.self) {
                    if !goalSet.shouldDisable($0) {
                        Text($0.menuDescription)
                            .tag($0)
                    }
                }
            }
        } label: {
            if pickedDietMacroGoalType == .percentageOfEnergy {
                if goalSet.energyGoal?.isDynamic == true {
                    PickerLabel(
                        pickedDietMacroGoalType.pickerDescription,
                        systemImage: "flame.fill",
                        imageColor: Color(hex: "F3DED7"),
                        backgroundGradientTop: Color(hex: AppleHealthTopColorHex),
                        backgroundGradientBottom: Color(hex: AppleHealthBottomColorHex),
                        foregroundColor: .white,
                        imageScale: .small
                    )
                } else {
                    PickerLabel(
                        pickedDietMacroGoalType.pickerDescription,
                        systemImage: "flame.fill"
                    )
                }

            } else {
                PickerLabel(pickedDietMacroGoalType.pickerDescription)
            }
        }
        .animation(.none, value: pickedDietMacroGoalType)
        .simultaneousGesture(TapGesture().onEnded {
            Haptics.feedback(style: .soft)
        })
    }
    
    var bodyMassTypePicker: some View {
        let binding = Binding<MacroGoalType.BodyMass>(
            get: { pickedBodyMassType },
            set: { newBodyMassType in
                withAnimation {
                    self.pickedBodyMassType = newBodyMassType
                }
                self.goal.macroGoalType = macroGoalType
            }
        )
        return Group {
            if !goal.isForMeal, pickedDietMacroGoalType == .gramsPerBodyMass {
                Menu {
                    Picker(selection: binding, label: EmptyView()) {
                        ForEach(MacroGoalType.BodyMass.allCases, id: \.self) {
                            Text($0.menuDescription).tag($0)
                        }
                    }
                } label: {
                    PickerLabel(
                        pickedBodyMassType.pickerDescription,
                        prefix: pickedBodyMassType.pickerPrefix
                    )
                }
                .animation(.none, value: pickedBodyMassType)
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
            }
        }
    }
    
    var workoutDurationUnitPicker: some View {
        let binding = Binding<WorkoutDurationUnit>(
            get: { pickedWorkoutDurationUnit },
            set: { newUnit in
                withAnimation {
                    self.pickedWorkoutDurationUnit = newUnit
                }
                self.goal.macroGoalType = macroGoalType
            }
        )
        return Group {
            if goal.isForMeal, pickedMealMacroGoalType == .gramsPerWorkoutDuration {
                Menu {
                    Picker(selection: binding, label: EmptyView()) {
                        ForEach(WorkoutDurationUnit.allCases, id: \.self) {
                            Text($0.pickerDescription).tag($0)
                        }
                    }
                } label: {
                    PickerLabel(
                        pickedWorkoutDurationUnit.menuDescription,
                        prefix: "per"
                    )
                }
                .animation(.none, value: pickedWorkoutDurationUnit)
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
                Text("of working out")
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
    
    var bodyMassUnitPicker: some View {
        let binding = Binding<WeightUnit>(
            get: { pickedBodyMassUnit },
            set: { newWeightUnit in
                withAnimation {
                    self.pickedBodyMassUnit = newWeightUnit
                }
                self.goal.macroGoalType = macroGoalType
            }
        )
        return Group {
            if !goal.isForMeal, pickedDietMacroGoalType == .gramsPerBodyMass {
                Menu {
                    Picker(selection: binding, label: EmptyView()) {
                        ForEach([WeightUnit.kg, WeightUnit.lb], id: \.self) {
                            Text($0.menuDescription).tag($0)
                        }
                    }
                } label: {
                    PickerLabel(
                        pickedBodyMassUnit.pickerDescription,
                        prefix: pickedBodyMassUnit.pickerPrefix
                    )
                }
                .animation(.none, value: pickedBodyMassUnit)
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
            }
        }
    }
}

extension GoalViewModel {
    @ViewBuilder
    var equivalentTextHStack: some View {
        if let equivalentUnitString {
            HStack(alignment: haveBothBounds ? .center : .firstTextBaseline) {
                Image(systemName: EqualSymbol)
                    .foregroundColor(Color(.tertiaryLabel))
                    .imageScale(.large)
                Spacer()
                if let lower = equivalentLowerBound {
                    if equivalentUpperBound == nil {
                        equivalentAccessoryText("at least")
                    }
                    HStack(spacing: 3) {
                        equivalentValueText(lower.formattedEnergy)
                        if equivalentUpperBound == nil {
                            equivalentUnitText(equivalentUnitString)
                        }
                    }
                }
                if let upper = equivalentUpperBound {
                    equivalentAccessoryText(equivalentLowerBound == nil ? "at most" : "to")
                    HStack(spacing: 3) {
                        equivalentValueText(upper.formattedEnergy)
                        equivalentUnitText(equivalentUnitString)
                    }
                }
            }
        }
    }
}

func equivalentAccessoryText(_ string: String) -> some View {
    Text(string)
//        .font(.system(.callout, design: .rounded, weight: .regular))
//        .foregroundColor(Color(.tertiaryLabel))
        .font(.system(.title3, design: .rounded, weight: .regular))
        .foregroundColor(Color(.tertiaryLabel))
}

func equivalentUnitText(_ string: String) -> some View {
    Text(string)
//        .font(.system(.subheadline, design: .rounded, weight: .regular))
//        .foregroundColor(Color(.tertiaryLabel))
        .font(.system(.body, design: .rounded, weight: .regular))
        .foregroundColor(Color(.tertiaryLabel))
}

func equivalentValueText(_ string: String) -> some View {
    Text(string)
        .monospacedDigit()
//        .font(.system(.body, design: .rounded, weight: .regular))
//        .foregroundColor(.secondary)
        .font(.system(.title2, design: .rounded, weight: .regular))
        .foregroundColor(.secondary)
}


extension GoalSetForm.ViewModel {
    func shouldDisable(_ type: DietMacroTypeOption) -> Bool {
        if type == .percentageOfEnergy {
            guard self.energyGoal != nil else {
                return true
            }
        }
        return false
    }
}

extension BodyProfile {
    static func mock(
        restingEnergy: Double? = nil,
        restingEnergySource: RestingEnergySourceOption = .userEntered,
        restingEnergyFormula: RestingEnergyFormula? = nil,
        activeEnergy: Double? = nil,
        activeEnergySource: ActiveEnergySourceOption = .userEntered,
        weight: Double? = nil,
        lbm: Double? = nil
    ) -> BodyProfile {
        BodyProfile(
            id: UUID(),
            parameters: Parameters(
                energyUnit: .kcal,
                weightUnit: .kg,
                heightUnit: .cm,
                restingEnergy: restingEnergy,
                restingEnergySource: restingEnergySource,
                restingEnergyFormula: restingEnergyFormula,
                activeEnergy: activeEnergy,
                activeEnergySource: activeEnergySource,
                lbm: lbm,
                lbmSource: .userEntered,
                weight: weight,
                weightSource: .userEntered
            ),
            syncStatus: .notSynced,
            updatedAt: Date().timeIntervalSince1970
        )
    }
}
