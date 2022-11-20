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
                .padding(.horizontal, 10)
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
        return FormStyledSection(header: Text("At least")) {
            HStack {
                DoubleTextField(double: binding, placeholder: "Optional")
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
                    HStack {
                        goal.equivalentTextHStack
                        Spacer()
                        Image(systemName: "flame.fill")
                            .foregroundColor(Color(.tertiaryLabel))
                        goalSet.energyGoal?.equivalentTextHStack
                    }
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
        return FormStyledSection(header: Text("At most")) {
            HStack {
                DoubleTextField(double: binding, placeholder: "Optional")
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
                Image(systemName: "bolt.horizontal.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                Color(hex: AppleHealthTopColorHex),
                                Color(hex: AppleHealthBottomColorHex)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
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
            }
            else if goal.isQuantityPerWorkoutDuration == true {
                Text("You can set your planned workout duration when creating a meal with this type.")
                /**
                 Text("Use this when you want to create a dynamic goal based on how long you workout for.")
                 Text("For e.g., you could create an \"intra-workout\" meal type that has a 0.5g/min carb goal.")
                 Text("You can then set or use your last workout time when creating a meal with this type.")
                 */
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
        if pickedDietMacroGoalType == .gramsPerBodyMass {
            FormStyledSection(header: Text("with"), footer: EmptyView()) {
                HStack {
                    bodyMassButton
                    Spacer()
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
    
    var bodyMassIsSyncedWithHealth: Bool {
        guard let params = goalSet.bodyProfile?.parameters, pickedDietMacroGoalType == .gramsPerBodyMass
        else { return false }
        
        switch pickedBodyMassType {
        case .weight:
            return params.weightUpdatesWithHealth == true
        case .leanMass:
            return params.lbmUpdatesWithHealth == true
        }
    }
    
    var energyIsSyncedWithHealth: Bool {
        guard pickedDietMacroGoalType == .percentageOfEnergy else { return false }
        return goalSet.bodyProfile?.parameters.updatesWithHealthApp == true
    }
    
    var isDynamic: Bool {
        bodyMassIsSyncedWithHealth || energyIsSyncedWithHealth
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
            switch pickedBodyMassType {
            case .weight:
                showingWeightForm = true
            case .leanMass:
                showingLeanMassForm = true
            }
        } label: {
            if haveBodyMass {
                if bodyMassIsSyncedWithHealth {
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
            PickerLabel(pickedDietMacroGoalType.pickerDescription)
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
                Text("working out")
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
            HStack {
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
                    equivalentAccessoryText(lowerBound == nil ? "up to" : "to")
                    HStack(spacing: 3) {
                        equivalentValueText(upper.formattedEnergy)
                        equivalentUnitText(equivalentUnitString)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .foregroundColor(Color(.secondarySystemFill))
            )
        }
    }
}

func equivalentAccessoryText(_ string: String) -> some View {
    Text(string)
        .font(.system(.callout, design: .rounded, weight: .regular))
        .foregroundColor(Color(.tertiaryLabel))
}

func equivalentUnitText(_ string: String) -> some View {
    Text(string)
        .font(.system(.caption2, design: .rounded, weight: .regular))
        .foregroundColor(Color(.tertiaryLabel))
}

func equivalentValueText(_ string: String) -> some View {
    Text(string)
        .monospacedDigit()
        .font(.system(.body, design: .rounded, weight: .regular))
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
                    Goal(type: .energy(.fixed(.kcal)), lowerBound: 500)
                ]
            ),
            bodyProfile: .mock(weight: 98)
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

extension BodyProfile {
    static func mock(weight: Double? = nil, lbm: Double? = nil) -> BodyProfile {
        BodyProfile(
            id: UUID(),
            parameters: Parameters(
                energyUnit: .kcal,
                weightUnit: .kg,
                heightUnit: .cm,
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



struct MacroForm_Previews: PreviewProvider {
    
    static var previews: some View {
        MacroFormPreview()
    }
}
