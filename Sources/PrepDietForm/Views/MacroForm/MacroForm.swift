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
            unitSection
            bodyMassSection
            equivalentSection
        }
        .navigationTitle("\(goal.macro?.description ?? "Macro")")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingWeightForm) { weightForm }
        .sheet(isPresented: $showingLeanMassForm) { leanMassForm }
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
    
    var bodyMassSection: some View {
        FormStyledSection(header: Text("Body Mass")) {
            HStack {
                bodyMassButton
                Spacer()
            }
        }
    }
    
    var haveBodyMass: Bool {
        true
    }
    
    var bodyMassIsSyncedWithHealth: Bool {
        true
    }
    
    var bodyMassFormattedWithUnit: String {
        "95 kg"
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
        FormStyledSection(footer: footer, horizontalPadding: 0) {
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
    
    @ViewBuilder
    var footer: some View {
        if goal.macroGoalType?.isGramsPerMinutesOfExercise == true {
            Text("You will be asked for the duration you plan to exercise for when you use this meal profile.")
        }
    }
    
    var lowerBoundSection: some View {
        let binding = Binding<Double?>(
            get: {
                return goal.lowerBound
            },
            set: {
                goal.lowerBound = $0
            }
        )
        return FormStyledSection(header: Text("At least")) {
            HStack {
                DoubleTextField(double: binding, placeholder: "Optional")
            }
        }
    }
    
    @ViewBuilder
    var equivalentSection: some View {
        if goal.energyGoalDelta != nil {
            FormStyledSection(header: Text("which Works out to be"), footer: footer) {
                Group {
                    Text("1570")
                    +
                    Text(" to ")
                        .foregroundColor(Color(.tertiaryLabel))
                        .font(.caption2)
                    +
                    Text("2205")
                    +
                    Text(" kcal")
                        .foregroundColor(Color(.tertiaryLabel))
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.secondary)
            }
        }
    }
    
    var upperBoundSection: some View {
        let binding = Binding<Double?>(
            get: { goal.upperBound },
            set: { goal.upperBound = $0 }
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
        Menu {
            Picker(selection: $pickedMealMacroGoalType, label: EmptyView()) {
                ForEach(MealMacroTypeOption.allCases, id: \.self) {
                    Text($0.menuDescription).tag($0)
                }
            }
        } label: {
            PickerLabel(pickedMealMacroGoalType.pickerDescription)
        }
    }
    
    var dietTypePicker: some View {
        Menu {
            Picker(selection: $pickedDietMacroGoalType, label: EmptyView()) {
                ForEach(DietMacroTypeOption.allCases, id: \.self) {
                    Text($0.menuDescription).tag($0)
                }
            }
        } label: {
            PickerLabel(pickedDietMacroGoalType.pickerDescription)
        }
    }
    
    @ViewBuilder
    var bodyMassTypePicker: some View {
        if !goal.isForMeal, pickedDietMacroGoalType == .gramsPerBodyMass {
            Menu {
                Picker(selection: $pickedBodyMassType, label: EmptyView()) {
                    ForEach(MacroGoalType.BodyMass.allCases, id: \.self) {
                        Text($0.menuDescription).tag($0)
                    }
                }
            } label: {
                PickerLabel(
                    pickedBodyMassType.pickerDescription,
                    prefix: pickedBodyMassType.pickerPrefix
                )
                .animation(.none, value: pickedBodyMassType)
            }
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
    }
    
    @ViewBuilder
    var bodyMassUnitPicker: some View {
        if !goal.isForMeal, pickedDietMacroGoalType == .gramsPerBodyMass {
            Menu {
                Picker(selection: $pickedBodyMassUnit, label: EmptyView()) {
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
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
    }
    
    @ViewBuilder
    var weightUnitMenu: some View {
        if goal.macroGoalType?.usesWeight == true {
            Menu {
                Button {
                    goal.macroBodyMassWeightUnit = .kg
                } label: {
                    Text("kilogram (kg)")
                }
                Button {
                    goal.macroBodyMassWeightUnit = .lb
                } label: {
                    Text("pound (lb)")
                }
            } label: {
                HStack {
                    Group {
                        if let weight = goal.macroBodyMassWeightUnit {
                            switch weight {
                            case .kg:
                                Text("in kg")
                            case .lb:
                                Text("in lb")
                            default:
                                Text("choose weight")
                                    .foregroundColor(Color(.quaternaryLabel))
                            }
                        } else {
                            Text("choose weight")
                                .foregroundColor(Color(.quaternaryLabel))
                        }
                    }
                    .fixedSize()
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity)
            }
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
    }
    
//    @ViewBuilder
//    var footer: some View {
//        if goal.energyGoalDelta != nil {
//            HStack {
//                Button {
//                    showingMaintenanceCalculator = true
//                } label: {
//                    Text("Your maintenance calories are 2,250 kcal.")
//                        .multilineTextAlignment(.leading)
//                }
//            }
//        }
//    }
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
            ])
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



struct MacroForm_Previews: PreviewProvider {
    
    static var previews: some View {
        MacroFormPreview()
    }
}
