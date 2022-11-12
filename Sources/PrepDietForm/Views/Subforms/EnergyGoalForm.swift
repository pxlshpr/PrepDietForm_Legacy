import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes

struct EnergyGoalForm: View {
    
    @ObservedObject var goal: GoalViewModel
    @State var pickedMealEnergyGoalType: MealEnergyGoalTypePickerOption
    @State var pickedDietEnergyGoalType: DietEnergyGoalTypePickerOption
    @State var pickedDelta: DeltaPickerOption

    @State var showingMaintenanceCalculator: Bool = false
    
    init(goal: GoalViewModel) {
        self.goal = goal
        //TODO: This isn't called after creating it and going back to the GoalSetForm
        // We may need to use a binding to the goal here instead and have bindings on the `GoalViewModel` that set and return the picker options (like MealEnergyGoalTypePickerOption). That would also make things cleaner and move it to the view model.
        let mealEnergyGoalType = MealEnergyGoalTypePickerOption(goalViewModel: goal) ?? .fixed
        let dietEnergyGoalType = DietEnergyGoalTypePickerOption(goalViewModel: goal)
        let delta = DeltaPickerOption(goalViewModel: goal)
        _pickedMealEnergyGoalType = State(initialValue: mealEnergyGoalType)
        _pickedDietEnergyGoalType = State(initialValue: dietEnergyGoalType)
        _pickedDelta = State(initialValue: delta)
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
        .navigationTitle("Energy")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: pickedMealEnergyGoalType, perform: mealEnergyGoalChanged)
        .onChange(of: pickedDietEnergyGoalType, perform: dietEnergyGoalChanged)
        .onChange(of: pickedDelta, perform: deltaChanged)
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
                Spacer()
                deltaMenu
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
    
    var unitView: some View {
        HStack {
            Text(goal.energyGoalType?.shortDescription ?? "")
                .foregroundColor(Color(.tertiaryLabel))
            if let difference = goal.energyGoalDelta {
                Spacer()
                Text(difference.description)
                    .foregroundColor(Color(.quaternaryLabel))
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
        //        Menu {
        //            typeOptions
        //        } label: {
        //            HStack(spacing: 5) {
        //                Text(goal.energyGoalType?.shortDescription ?? "")
        //                    .frame(maxHeight: .infinity)
        //                    .fixedSize()
        //                Image(systemName: "chevron.up.chevron.down")
        //                    .imageScale(.small)
        //            }
        //            .frame(maxHeight: .infinity)
        //            .frame(maxWidth: .infinity, alignment: .leading)
        //        }
        //        .contentShape(Rectangle())
        //        .simultaneousGesture(TapGesture().onEnded {
        //            Haptics.feedback(style: .soft)
        //        })
    }
    
    var mealTypePicker: some View {
        Menu {
            Picker("", selection: $pickedMealEnergyGoalType) {
                ForEach(MealEnergyGoalTypePickerOption.allCases, id: \.self) {
                    Text($0.description(userEnergyUnit: .kcal)).tag($0)
                }
            }
        } label: {
            PickerLabel(pickedMealEnergyGoalType.description(userEnergyUnit: .kcal))
        }
    }
    
    var dietTypePicker: some View {
        Menu {
            Picker(selection: $pickedDietEnergyGoalType, label: EmptyView()) {
                ForEach(DietEnergyGoalTypePickerOption.allCases, id: \.self) {
                    Text($0.description(userEnergyUnit: .kcal)).tag($0)
                }
            }
        } label: {
            PickerLabel(pickedDietEnergyGoalType.shortDescription(userEnergyUnit: .kcal))
        }
    }
    
    @ViewBuilder
    var deltaMenu: some View {
        if !goal.isForMeal, pickedDietEnergyGoalType != .fixed {
            HStack {
                Menu {
                    Picker(selection: $pickedDelta, label: EmptyView()) {
                        ForEach(DeltaPickerOption.allCases, id: \.self) {
                            Text($0.description).tag($0)
                        }
                    }
                } label: {
                    PickerLabel(pickedDelta.description)
                }
                .contentShape(Rectangle())
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
                Text("maintenance")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

extension EnergyGoalForm {
    enum MealEnergyGoalTypePickerOption: CaseIterable {
        
        case fixed
        case percentageOfDailyTotal
        
        func description(userEnergyUnit energyUnit: EnergyUnit) -> String {
            switch self {
            case .fixed: return energyUnit.shortDescription
            case .percentageOfDailyTotal: return "% of daily total"
            }
        }
        
        init?(goalViewModel: GoalViewModel) {
            switch goalViewModel.energyGoalType {
            case .percentOfDietGoal:
                self = .percentageOfDailyTotal
            case .fixed:
                self = .fixed
            default:
                return nil
            }
        }
    }
    
    enum DietEnergyGoalTypePickerOption: CaseIterable {
        
        case fixed
        case fromMaintenance
        case percentageFromMaintenance
        
        func description(userEnergyUnit energyUnit: EnergyUnit) -> String {
            switch self {
            case .fixed:
                return energyUnit.shortDescription
            case .fromMaintenance:
                return energyUnit.shortDescription + " from maintenance"
            case .percentageFromMaintenance:
                return "% from maintenance"
            }
        }
        
        func shortDescription(userEnergyUnit energyUnit: EnergyUnit) -> String {
            switch self {
            case .fixed, .fromMaintenance:
                return energyUnit.shortDescription
            case .percentageFromMaintenance:
                return "%"
            }
        }
        
        init(goalViewModel: GoalViewModel) {
            self = .fixed
        }
    }
    
    enum DeltaPickerOption: CaseIterable {
        case below
        case above
        
        var description: String {
            switch self {
            case .above:
                return "above"
            case .below:
                return "below"
            }
        }
        
        init(goalViewModel: GoalViewModel) {
            self = .below
        }
    }
}

extension GoalViewModel {
    var energyUnit: EnergyUnit? {
        switch energyGoalType {
        case .fixed(let energyUnit):
            return energyUnit
        case .fromMaintenance(let energyUnit, _):
            return energyUnit
        default:
            return nil
        }
    }
}
//MARK: - Convenience
extension EnergyGoalForm {
    
    var energyUnit: EnergyUnit {
        goal.energyUnit ?? .kcal
    }
    
    var energyDelta: EnergyDelta {
        switch pickedDelta {
        case .below:
            return .deficit
        case .above:
            return .surplus
        }
    }
    
    var energyGoalType: EnergyGoalType? {
        if goal.isForMeal {
            switch pickedMealEnergyGoalType {
            case .fixed:
                return .fixed(energyUnit)
            case .percentageOfDailyTotal:
                return .percentOfDietGoal
            }
        } else {
            switch pickedDietEnergyGoalType {
            case .fixed:
                return .fixed(energyUnit)
            case .fromMaintenance:
                return .fromMaintenance(energyUnit, energyDelta)
            case .percentageFromMaintenance:
                return .percentFromMaintenance(energyDelta)
            }
        }
    }
}

//MARK: - Actions
extension EnergyGoalForm {
    
    func dietEnergyGoalChanged(_ newValue: DietEnergyGoalTypePickerOption) {
        goal.energyGoalType = self.energyGoalType
    }
    
    func mealEnergyGoalChanged(_ newValue: MealEnergyGoalTypePickerOption) {
        
    }
    
    func deltaChanged(to newValue: DeltaPickerOption) {
        goal.energyGoalType = self.energyGoalType
    }
}

struct EnergyGoalFormPreview: View {
    
    @StateObject var goalViewModel = GoalViewModel(type: .energy(.fixed(.kcal)))
    
    var body: some View {
        NavigationView {
            EnergyGoalForm(goal: goalViewModel)
        }
    }
}



struct EnergyGoalForm_Previews: PreviewProvider {
    
    static var previews: some View {
        EnergyGoalFormPreview()
    }
}

