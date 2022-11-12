import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes

extension WeightUnit {
    var menuDescription: String {
        switch self {
        case .kg:
            return "kilogram"
        case .lb:
            return "pound"
        default:
            return "unsupported"
        }
    }
    
    var pickerDescription: String {
        switch self {
        case .kg:
            return "per kilogram"
        case .lb:
            return "per pound"
        default:
            return "unsupported"
        }
    }
}
struct MacroGoalForm: View {
    
    enum MealMacroGoalTypePickerOption: CaseIterable {
        case fixed
        case gramsPerMinutesOfActivity
        
        init(goalViewModel: GoalViewModel) {
            self = .fixed
        }
        
        var menuDescription: String {
            switch self {
            case .fixed:
                return "grams"
            case .gramsPerMinutesOfActivity:
                return "grams / mins of exercise"
            }
        }
        
        var pickerDescription: String {
            switch self {
            case .fixed:
                return "g"
            case .gramsPerMinutesOfActivity:
                return "g / mins of exercise"
            }
        }
    }
    
    enum DietMacroGoalTypePickerOption: CaseIterable {
        case fixed
        case gramsPerBodyMass
        case percentageOfEnergy
        
        init(goalViewModel: GoalViewModel) {
            self = .fixed
        }
        
        var menuDescription: String {
            switch self {
            case .fixed:
                return "grams"
            case .gramsPerBodyMass:
                return "grams / body mass"
            case .percentageOfEnergy:
                return "% of energy"
            }
        }
        
        var pickerDescription: String {
            switch self {
            case .fixed, .gramsPerBodyMass:
                return "g"
            case .percentageOfEnergy:
                return "% of energy"
            }
        }
    }
    
    @EnvironmentObject var goalSet: GoalSetForm.ViewModel
    @ObservedObject var goal: GoalViewModel
    
    @State var pickedMealMacroGoalType: MealMacroGoalTypePickerOption
    @State var pickedDietMacroGoalType: DietMacroGoalTypePickerOption
    @State var pickedBodyMassType: BodyMassType
    @State var pickedBodyMassUnit: WeightUnit
    
    @State var showingMaintenanceCalculator: Bool = false
    
    init(goal: GoalViewModel) {
        self.goal = goal
        let pickedMealMacroGoalType = MealMacroGoalTypePickerOption(goalViewModel: goal)
        let pickedDietMacroGoalType = DietMacroGoalTypePickerOption(goalViewModel: goal)
        let bodyMassType = goal.bodyMassType ?? .weight
        let bodyMassUnit = goal.bodyMassUnit ?? .kg // TODO: User's default unit here
        _pickedMealMacroGoalType = State(initialValue: pickedMealMacroGoalType)
        _pickedDietMacroGoalType = State(initialValue: pickedDietMacroGoalType)
        _pickedBodyMassType = State(initialValue: bodyMassType)
        _pickedBodyMassUnit = State(initialValue: bodyMassUnit)
    }
    
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
        .sheet(isPresented: $showingMaintenanceCalculator) { maintenanceCalculator }
    }
    
    var maintenanceCalculator: some View {
        MaintenanceEnergySettings()
            .presentationDetents([.medium, .large])
    }

    var unitSection: some View {
        FormStyledSection(header: Text("Unit"), verticalPadding: 0) {
            HStack {
                typePicker
                bodyMassUnitPicker
                bodyMassTypePicker
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
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
                ForEach(MealMacroGoalTypePickerOption.allCases, id: \.self) {
                    Text($0.menuDescription).tag($0)
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text(pickedMealMacroGoalType.pickerDescription)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
            .frame(maxHeight: .infinity)
            .fixedSize(horizontal: true, vertical: false)
        }
    }
    
    var dietTypePicker: some View {
        Menu {
            Picker(selection: $pickedDietMacroGoalType, label: EmptyView()) {
                ForEach(DietMacroGoalTypePickerOption.allCases, id: \.self) {
                    Text($0.menuDescription).tag($0)
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text(pickedDietMacroGoalType.pickerDescription)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
            .frame(maxHeight: .infinity)
            .fixedSize(horizontal: true, vertical: false)
        }
    }
    
    @ViewBuilder
    var bodyMassTypePicker: some View {
        if !goal.isForMeal, pickedDietMacroGoalType == .gramsPerBodyMass {
            Menu {
                Picker(selection: $pickedBodyMassType, label: EmptyView()) {
                    ForEach(BodyMassType.allCases, id: \.self) {
                        Text($0.menuDescription).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(pickedBodyMassType.pickerDescription)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .frame(maxHeight: .infinity)
                .fixedSize(horizontal: true, vertical: false)
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
                HStack(spacing: 5) {
                    Text(pickedBodyMassUnit.pickerDescription)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .frame(maxHeight: .infinity)
                .fixedSize(horizontal: true, vertical: false)
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
    
    @ViewBuilder
    var footer: some View {
        if goal.energyGoalDelta != nil {
            HStack {
                Button {
                    showingMaintenanceCalculator = true
                } label: {
                    Text("Your maintenance calories are 2,250 kcal.")
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}


struct MacroGoalFormPreview: View {
    
    @StateObject var goalSetViewModel = GoalSetForm.ViewModel(
        isMealProfile: true,
        existingGoalSet: GoalSet(name: "Bulking", emoji: "", goals: [
            Goal(type: .energy(.fromMaintenance(.kcal, .deficit)), lowerBound: 500)
        ])
    )
    @StateObject var goalViewModel = GoalViewModel(type: .macro(.fixed, .carb))
    
    var body: some View {
        NavigationView {
            MacroGoalForm(goal: goalViewModel)
                .environmentObject(goalSetViewModel)
        }
    }
}



struct MacroGoalForm_Previews: PreviewProvider {
    
    static var previews: some View {
        MacroGoalFormPreview()
    }
}
