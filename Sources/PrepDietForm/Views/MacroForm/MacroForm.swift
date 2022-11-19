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
    
    @State var showingLeanMassForm: Bool = false
    @State var showingWeightForm: Bool = false
    
    init(goal: GoalViewModel) {
        self.goal = goal
        let pickedMealMacroGoalType = MealMacroTypeOption(goalViewModel: goal) ?? .fixed
        let pickedDietMacroGoalType = DietMacroTypeOption(goalViewModel: goal) ?? .fixed
        let bodyMassType = goal.bodyMassType ?? .weight
        let bodyMassUnit = goal.bodyMassUnit ?? .kg // TODO: User's default unit here
        _pickedMealMacroGoalType = State(initialValue: pickedMealMacroGoalType)
        _pickedDietMacroGoalType = State(initialValue: pickedDietMacroGoalType)
        _pickedBodyMassType = State(initialValue: bodyMassType)
        _pickedBodyMassUnit = State(initialValue: bodyMassUnit)
    }
}

extension MacroForm {
    
    var body: some View {
        FormStyledScrollView {
            HStack(spacing: 0) {
                lowerBoundSection
                upperBoundSection
            }
//            .background(.green)
            unitSection
//                .background(.green)
            bodyMassSection
//                .background(.green)
            equivalentSection
//                .background(.green)
        }
        .navigationTitle("\(goal.macro?.description ?? "Macro")")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { trailingContent }
        .sheet(isPresented: $showingWeightForm) { weightForm }
        .sheet(isPresented: $showingLeanMassForm) { leanMassForm }
        .onDisappear(perform: goal.validateMacro)
    }
    
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
            } else if goal.macroGoalType?.isGramsPerMinutesOfExercise == true {
                Text("You will be asked for the duration you plan to exercise for when you use this meal profile.")
            }
        }
    }
    
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

    var unitSection: some View {
        FormStyledSection(footer: unitsFooter, horizontalPadding: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    typePicker
                    bodyMassUnitPicker
                    bodyMassTypePicker
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
                        if let lower = goal.equivalentLowerBound {
                            if goal.equivalentUpperBound == nil {
                                equivalentAccessoryText("at least")
                            }
                            HStack(spacing: 3) {
                                equivalentValueText(lower.formattedMacro)
                                if goal.equivalentUpperBound == nil {
                                    equivalentUnitText("g")
                                }
                            }
                        }
                        if let upper = goal.equivalentUpperBound {
                            equivalentAccessoryText(goal.lowerBound == nil ? "up to" : "to")
                            HStack(spacing: 3) {
                                equivalentValueText(upper.formattedMacro)
                                equivalentUnitText("g")
                            }
                        }
                        Spacer()
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
                    Text($0.menuDescription).tag($0)
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

struct MacroFormPreview: View {
    
    @StateObject var goalSet: GoalSetForm.ViewModel
    @StateObject var goal: GoalViewModel
    
    init() {
        let goalSet = GoalSetForm.ViewModel(
            userUnits: .standard,
            isMealProfile: false,
            existingGoalSet: GoalSet(name: "Bulking", emoji: "", goals: [
                Goal(type: .energy(.fromMaintenance(.kcal, .deficit)), lowerBound: 500)
            ]),
            bodyProfile: .mock(weight: 98)
        )
        let goal = GoalViewModel(
            goalSet: goalSet,
            type: .macro(.gramsPerBodyMass(.weight, .kg), .protein)
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
