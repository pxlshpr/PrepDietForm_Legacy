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
    
    @State var showingMaintenanceCalculator: Bool = false
    
    init(goal: GoalViewModel) {
        self.goal = goal
        let pickedMealMacroGoalType = MealMacroTypeOption(goalViewModel: goal)
        let pickedDietMacroGoalType = DietMacroTypeOption(goalViewModel: goal)
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
            equivalentSection
        }
        .navigationTitle("\(goal.macro?.description ?? "Macro")")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingMaintenanceCalculator) { tdeeForm }
    }
    
    var tdeeForm: some View {
        TDEEForm { profile in
            
        }
    }

    var unitSection: some View {
        FormStyledSection(header: Text("Unit"), footer: footer, horizontalPadding: 0, verticalPadding: 0) {
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
            .frame(height: 50)
        }
    }
    
    @ViewBuilder
    var footer: some View {
        Color.clear
//        if goal.macroGoalType == .gramsPerMinutesOfActivity {
//            Text("You will be asked for the duration you plan to exercise for when you use this meal profile.")
//        }
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
    
    @StateObject var goalSetViewModel = GoalSetForm.ViewModel(
        isMealProfile: true,
        existingGoalSet: GoalSet(name: "Bulking", emoji: "", goals: [
            Goal(type: .energy(.fromMaintenance(.kcal, .deficit)), lowerBound: 500)
        ])
    )
    @StateObject var goalViewModel = GoalViewModel(type: .macro(.fixed, .carb))
    
    var body: some View {
        NavigationView {
            MacroForm(goal: goalViewModel)
                .environmentObject(goalSetViewModel)
        }
    }
}



struct MacroForm_Previews: PreviewProvider {
    
    static var previews: some View {
        MacroFormPreview()
    }
}
