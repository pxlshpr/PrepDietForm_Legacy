import SwiftUI
import SwiftUISugar
import SwiftHaptics

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
        .navigationTitle("Energy Goal")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingMaintenanceCalculator) { maintenanceCalculator }
    }
    
    var maintenanceCalculator: some View {
        Text("Maintenance Calculator goes here")
            .presentationDetents([.medium, .large])
    }

    var unitSection: some View {
        FormStyledSection(header: Text("Unit"), verticalPadding: 0) {
            HStack {
                typeMenu
                Spacer()
                differenceMenu
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
    
    var unitView: some View {
        HStack {
            Text(goal.energyGoalType?.shortDescription ?? "")
                .foregroundColor(Color(.tertiaryLabel))
            if let difference = goal.energyGoalDifference {
                Spacer()
                Text(difference.description)
                    .foregroundColor(Color(.quaternaryLabel))
            }
        }
    }
    
    var typeMenu: some View {
        Menu {
            ForEach(EnergyGoalType.allCases, id: \.self) { type in
                Button {
                    withAnimation {
                        goal.energyGoalType = type
                        if goal.energyGoalType == .percentage, goal.energyGoalDifference == nil {
                            goal.energyGoalDifference = .deficit
                        }
                    }
                } label: {
                    Label(type.description, systemImage: type.systemImage)
                }
                .disabled(self.goal.energyGoalType == type)
            }
        } label: {
            HStack(spacing: 5) {
                Text(goal.energyGoalType?.shortDescription ?? "")
                    .frame(maxHeight: .infinity)
                    .fixedSize()
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
            .frame(maxHeight: .infinity)
//            .frame(maxWidth: 60, alignment: .leading)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded {
            Haptics.feedback(style: .soft)
        })
    }
    
    var differenceMenu: some View {
        Menu {
            ForEach(EnergyGoalDifference.allCases, id: \.self) { difference in
                Button {
                    withAnimation {
                        goal.energyGoalDifference = difference
                    }
                } label: {
                    Label(difference.description, systemImage: difference.systemImage)
                }
                .disabled(goal.energyGoalDifference == difference)
            }
            if goal.energyGoalDifference != nil, goal.energyGoalType == .fixed {
                Divider()
                Button(role: .destructive) {
                    withAnimation {
                        goal.energyGoalDifference = nil
                    }
                } label: {
                    Label("Remove", systemImage: "minus.circle")
                }
            }
        } label: {
            HStack {
                Group {
                    if let difference = goal.energyGoalDifference {
                        Text(difference.description)
                    } else {
                        Text("above / below maintenance")
                            .foregroundColor(Color(.quaternaryLabel))
                    }
                }
                .fixedSize()
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
            .frame(maxHeight: .infinity)
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded {
            Haptics.feedback(style: .soft)
        })
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


struct EnergyGoalFormPreview: View {
    
    @StateObject var goalViewModel = GoalViewModel(type: .energy(.kcal, nil))
    
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
