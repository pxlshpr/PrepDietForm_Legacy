import SwiftUI
import SwiftUISugar
import PrepDataTypes
import SwiftHaptics

let EqualSymbol = "equal.square"

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
        .background(backgroundColor)
        .cornerRadius(10)
        .padding(.bottom, 10)
    }
    
    var backgroundColor: Color {
        goal.isAutoGenerated ? Color(.secondarySystemGroupedBackground) : Color(.secondarySystemGroupedBackground)
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
            dynamicIndicator
            autoGeneratedIndicator
            disclosureArrow
        }
        .foregroundColor(labelColor)
    }
    
    @ViewBuilder
    var dynamicIndicator: some View {
        if goal.isDynamic {
            appleHealthBolt
                .imageScale(.small)
        }
    }
    
    @ViewBuilder
    var autoGeneratedIndicator: some View {
        if goal.isAutoGenerated {
            Image(systemName: "sparkles")
                .imageScale(.small)
//            Text("Auto generated")
            Text("Auto")
                .textCase(.uppercase)
                .font(.footnote)
        }
    }
    
    var shouldShowType: Bool {
        guard goal.hasOneBound else { return false }
//        if goal.equivalentLowerBound == nil && goal.equivalentUpperBound == nil {
//            return true
//        }
        guard !showingEquivalentValues else { return false }
        return goal.type.showsEquivalentValues
    }
    
    @ViewBuilder
    var typeText: some View {
        if shouldShowType,
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
        guard !goal.isAutoGenerated else {
            return Color(.tertiaryLabel)
        }
        guard !isEmpty else {
            return Color(.secondaryLabel)
        }
        return goal.type.labelColor(for: colorScheme)
    }
    
    func amountText(_ double: Double) -> Text {
        Text("\(double.formattedGoalValue)")
            .foregroundColor(amountColor)
            .font(.system(size: isEmpty ? 20 : 28, weight: .medium, design: .rounded))
    }
    
    var isEmpty: Bool {
        goal.lowerBound == nil && goal.upperBound == nil
    }
    
    var amountColor: Color {
        guard !goal.isAutoGenerated else {
            return Color(.tertiaryLabel)
        }
        return isEmpty ? Color(.quaternaryLabel) : Color(.label)
    }

    var unitColor: Color {
        goal.isAutoGenerated ? Color(.tertiaryLabel) : Color(.secondaryLabel)
    }
    func unitText(_ string: String) -> Text {
        Text(string)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .bold()
            .foregroundColor(unitColor)
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
            bottomRowTexts
            Spacer()
        }
        .frame(minHeight: 35)
    }
    
    var placeholderText: String? {
        guard let placeholderText = goal.placeholderText else {
            return nil
        }
        /// If the goal has at least one value
        if goal.hasOneBound {
            /// Only show the placeholder text (if available) when showing equivalent values
            guard showingEquivalentValues else {
                return nil
            }
        }
        
        return placeholderText
    }
    
    var placeholderTextColor: Color {
        goal.placeholderTextColor ?? Color(.quaternaryLabel)
    }
    
    @ViewBuilder
    var bottomRowTexts: some View {
        if goal.type.showsEquivalentValues && showingEquivalentValues {
            equivalentTexts
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .scale.combined(with: .opacity).combined(with: .move(edge: .bottom))
                ))
        } else {
            texts
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .scale.combined(with: .opacity).combined(with: .move(edge: .bottom))
                ))
        }
    }
    
    @ViewBuilder
    var texts: some View {
        if let placeholderText {
            Text(placeholderText)
                .foregroundColor(placeholderTextColor)
                .font(.system(size: 20, weight: .medium, design: .rounded))
        } else {
            HStack {
                if let lowerBound {
                    if upperBound == nil {
                        accessoryText("at least")
                    }
                    amountAndUnitTexts(lowerBound, upperBound == nil ? unitString : nil)
                }
                if let upperBound {
                    accessoryText(lowerBound == nil ? "below" : "to")
                    amountAndUnitTexts(upperBound, unitString)
                }
            }
        }
    }
    
    var equalSymbol: some View {
        Image(systemName: EqualSymbol)
            .foregroundColor(Color(.secondaryLabel))
            .transition(.asymmetric(
                insertion: .move(edge: .leading),
                removal: .scale.combined(with: .opacity).combined(with: .move(edge: .bottom))
            ))
    }
    
    @ViewBuilder
    var equivalentTexts: some View {
        if let placeholderText {
            Text(placeholderText)
                .foregroundColor(placeholderTextColor)
                .font(.system(size: 20, weight: .medium, design: .rounded))
        } else {
            HStack {
//                if showingEquivalentValues {
//                    equalSymbol
//                }
                if let lowerBound {
                    if upperBound == nil {
                        accessoryText("at least")
                    }
                    amountAndUnitTexts(lowerBound, upperBound == nil ? unitString : nil)
                }
                if let upperBound {
                    accessoryText(lowerBound == nil ? "below" : "to")
                    amountAndUnitTexts(upperBound, unitString)
                }
            }
        }
    }
    
    @ViewBuilder
    var disclosureArrow: some View {
        if !goal.isAutoGenerated {
            Image(systemName: "chevron.forward")
                .font(.system(size: 14))
                .foregroundColor(Color(.tertiaryLabel))
                .fontWeight(.semibold)
        }
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
