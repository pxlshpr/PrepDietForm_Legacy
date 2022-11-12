import SwiftUI
import SwiftUISugar
import SwiftHaptics

struct MacroGoalForm: View {
    
    @EnvironmentObject var goalSet: GoalSetForm.ViewModel
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
                typeMenu
                perMenu
                weightUnitMenu
//                Spacer()
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
        if goal.energyGoalDifference != nil {
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

    var typeMenu: some View {
        Menu {
//            ForEach(MacroGoalType.units, id: \.self.0) { (unit, systemImage) in
                Button {
                    goal.macroGoalType = .fixed
                } label: {
                    Text("grams")
                }
                Button {
                    goal.macroGoalType = .percentageOfEnergy
                } label: {
                    Text("% of energy goal")
                }
                .disabled(!goalSet.goals.containsEnergy)
//            }
        } label: {
            HStack(spacing: 5) {
                Group {
                    switch goal.macroGoalType {
                    case .percentageOfEnergy:
                        Text("% of energy goal")
                    default:
                        Text("g")
                    }
                }
                .frame(maxHeight: .infinity)
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
    
    
    @ViewBuilder
    var perMenu: some View {
        if goal.macroGoalType?.isPercent == false {
            Menu {
                Button {
                    goal.macroGoalType = .gramsPerBodyMass(.weight, .kg) //TODO: Use the user's default weight here
                } label: {
                    Text("per weight")
                }
                Button {
                    goal.macroGoalType = .gramsPerBodyMass(.leanMass, .kg) //TODO: Use the user's default weight here
                } label: {
                    Text("per lean body mass")
                }
                if goalSet.isMealProfile {
                    Button {
                        goal.macroGoalType = .gramsPerMinutesOfActivity
                    } label: {
                        Text("per minutes of workout")
                    }
                }
            } label: {
                HStack {
                    Group {
                        switch goal.macroGoalType {
                        case .gramsPerBodyMass(let bodyMassType, _):
                            Text("per \(bodyMassType.description)")
                        case .gramsPerMinutesOfActivity:
                            Text("per minutes of exercise")
                        default:
                            Text("per")
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
        if goal.energyGoalDifference != nil {
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
            Goal(type: .energy(.kcal, .deficit), lowerBound: 500)
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
