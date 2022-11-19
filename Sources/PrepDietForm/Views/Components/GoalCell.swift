import SwiftUI
import SwiftUISugar
import PrepDataTypes
import SwiftHaptics

struct GoalCell: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var goal: GoalViewModel
    @Binding var showingEquivalentValues: Bool
    
    var body: some View {
        ZStack {
            content
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.bottom, 10)
    }
    
    var content: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                topRow
                bottomRow
            }
        }
    }
    
    var topRow: some View {
        HStack {
            Spacer().frame(width: 2)
            HStack(spacing: 4) {
                Image(systemName: goal.type.systemImage)
                    .font(.system(size: 14))
                Text(goal.type.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            Spacer()
            typeText
            disclosureArrow
        }
        .foregroundColor(labelColor)
    }
    
    @ViewBuilder
    var typeText: some View {
        if (!showingEquivalentValues || !goal.type.showsEquivalentValues),
           let string = goal.type.accessoryDescription,
           let icon = goal.type.accessorySystemImage
        {
            HStack {
                Image(systemName: icon)
                Text(string)
            }
            .foregroundColor(Color(.secondaryLabel))
            .font(.caption)
        }
    }
    
    var labelColor: Color {
        guard !isEmpty else {
            return Color(.secondaryLabel)
        }
        return goal.type.labelColor(for: colorScheme)
    }
    
    func amountText(_ double: Double) -> Text {
        Text("\(double.formattedEnergy)")
            .foregroundColor(amountColor)
            .font(.system(size: isEmpty ? 20 : 28, weight: .medium, design: .rounded))
    }
    
    var isEmpty: Bool {
        goal.lowerBound == nil && goal.upperBound == nil
    }
    
    var amountColor: Color {
        isEmpty ? Color(.quaternaryLabel) : Color(.label)
    }

    func unitText(_ string: String) -> Text {
        Text(string)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .bold()
            .foregroundColor(Color(.secondaryLabel))
    }
    
    func amountAndUnitTexts(_ amount: Double, _ unit: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            amountText(amount)
                .multilineTextAlignment(.leading)
            if !isEmpty, let unit {
                unitText(unit)
            }
        }
    }
    
    func accessoryText(_ string: String) -> some View {
        Text(string)
            .font(.title3)
            .textCase(.lowercase)
            .foregroundColor(Color(.tertiaryLabel))
    }
    
    var bottomRow: some View {
        HStack {
            if let lowerBound {
                if upperBound == nil {
                    accessoryText("at least")
                }
                amountAndUnitTexts(lowerBound, upperBound == nil ? unitString : nil)
            } else if upperBound == nil {
                Text("Set Goal")
                    .foregroundColor(amountColor)
                    .font(.system(size: isEmpty ? 20 : 28, weight: .medium, design: .rounded))
            }
            if let upperBound {
                accessoryText(lowerBound == nil ? "up to" : "to")
                amountAndUnitTexts(upperBound, unitString)
            }
            Spacer()
        }
    }
    
    var disclosureArrow: some View {
        Image(systemName: "chevron.forward")
            .font(.system(size: 14))
            .foregroundColor(Color(.tertiaryLabel))
            .fontWeight(.semibold)
    }
    
    var upperBound: Double? {
        if showingEquivalentValues, let upperBound = goal.equivalentUpperBound {
            return upperBound
        } else {
            return goal.upperBound
        }
    }
    
    var lowerBound: Double? {
        if showingEquivalentValues, let lowerBound = goal.equivalentLowerBound {
            return lowerBound
        } else {
            return goal.lowerBound
        }
    }
    
    var unitString: String {
        if showingEquivalentValues, let unitString = goal.equivalentUnitString {
            return unitString
        } else {
            return goal.type.unitString
        }
    }
}
