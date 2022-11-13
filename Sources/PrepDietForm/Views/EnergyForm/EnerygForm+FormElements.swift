import SwiftUI
import SwiftUISugar

extension EnergyForm {
    
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
    var footer: some View {
        if goal.energyGoalDelta != nil {
            HStack {
                Button {
                    showingMaintenanceEnergyForm = true
                } label: {
                    Text("Your maintenance calories are 2,250 kcal.")
                        .multilineTextAlignment(.leading)
                }
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
}
