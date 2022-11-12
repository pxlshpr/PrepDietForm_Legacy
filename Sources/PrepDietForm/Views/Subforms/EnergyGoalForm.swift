import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes

struct EnergyGoalForm: View {
    
    @ObservedObject var goal: GoalViewModel
    @State var showingMaintenanceCalculator: Bool = false
    
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
    
    enum MealTypePickerOption: CaseIterable {
        
        case fixed
        case percentageOfDailyTotal
        
        func description(userEnergyUnit energyUnit: EnergyUnit) -> String {
            switch self {
            case .fixed: return energyUnit.shortDescription
            case .percentageOfDailyTotal: return "% of daily total"
            }
        }
    }
    
    @State var pickedMealType: MealTypePickerOption = .fixed
    
    var mealTypePicker: some View {
        Picker("", selection: $pickedMealType) {
            ForEach(MealTypePickerOption.allCases, id: \.self) {
                Text($0.description(userEnergyUnit: .kcal)).tag($0)
            }
        }
        .onChange(of: pickedMealType) { newValue in
            print("pickedMealType changed to: \(newValue)")
        }
    }
    
    enum DietTypePickerOption: CaseIterable {
        
        case fixed
        case percentage
        
        func description(userEnergyUnit energyUnit: EnergyUnit) -> String {
            switch self {
            case .fixed: return energyUnit.shortDescription
            case .percentage: return "%"
            }
        }
    }
    
    @State var pickedDietType: DietTypePickerOption = .fixed
    
    var dietTypePicker: some View {
        Picker("", selection: $pickedDietType) {
            ForEach(DietTypePickerOption.allCases, id: \.self) {
                Text($0.description(userEnergyUnit: .kcal)).tag($0)
            }
        }
        .onChange(of: pickedMealType) { newValue in
            print("pickedDietType changed to: \(newValue)")
        }
    }
    
    @ViewBuilder
    var deltaMenu: some View {
        if !goal.isForMeal {
            Text("Delta Menu")
        }
//        Menu {
//            ForEach(EnergyDelta.allCases, id: \.self) { difference in
//                Button {
//                    withAnimation {
//                        goal.energyGoalDifference = difference
//                    }
//                } label: {
//                    Label(difference.description, systemImage: difference.systemImage)
//                }
//                .disabled(goal.energyGoalDifference == difference)
//            }
//            if goal.energyGoalDifference != nil, goal.energyGoalType == .fixed {
//                Divider()
//                Button(role: .destructive) {
//                    withAnimation {
//                        goal.energyGoalDifference = nil
//                    }
//                } label: {
//                    Label("Remove", systemImage: "minus.circle")
//                }
//            }
//        } label: {
//            HStack {
//                Group {
//                    if let difference = goal.energyGoalDifference {
//                        Text(difference.description)
//                    } else {
//                        Text("relative to maintenance")
//                            .foregroundColor(Color(.quaternaryLabel))
//                    }
//                }
//                .fixedSize()
//                Image(systemName: "chevron.up.chevron.down")
//                    .imageScale(.small)
//            }
//            .frame(maxHeight: .infinity)
//            .frame(maxWidth: .infinity)
//        }
//        .contentShape(Rectangle())
//        .simultaneousGesture(TapGesture().onEnded {
//            Haptics.feedback(style: .soft)
//        })
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
