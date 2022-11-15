import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes
import HealthKit

extension TDEEForm {
    
    enum Route: Hashable {
        case healthAppPeriod
        case fatPercentageForm
        case weightForm
        case heightForm
    }

    func initialTask() async {
        guard let restingEnergy = await HealthKitManager.shared.getLatestRestingEnergy() else {
            return
        }
        await MainActor.run {
            self.healthRestingEnergy = restingEnergy
        }

        guard let activeEnergy = await HealthKitManager.shared.getLatestActiveEnergy() else {
            return
        }
        await MainActor.run {
            self.healthActiveEnergy = activeEnergy
        }
    }
    
    var maintenanceEnergy: Double? {
        guard let healthActiveEnergy, let healthRestingEnergy else {
            return nil
        }
        return healthActiveEnergy + healthRestingEnergy
    }
    
    var title: String {
        guard let maintenanceEnergy else {
            return "Maintenace Energy"
        }
        return maintenanceEnergy.formattedEnergy + " kcal"
    }
    
    var trailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                toggleEditState()
            } label: {
                Text(isEditing ? "Save" : "Edit")
//                Image(systemName: isEditing ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
            }
//            if valuesHaveChanged {
//                Button {
//                    Haptics.successFeedback()
//                    dismiss()
//                } label: {
//                    Text("Save")
//                        .bold()
//                }
//            }
        }
    }

    var leadingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                Haptics.feedback(style: .soft)
                dismiss()
            } label: {
                closeButtonLabel
            }
        }
    }

    var principalContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(alignment: .center) {
                Text("4,024")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text("kcal")
                    .foregroundColor(.secondary)
            }
//            if maintenanceEnergy != nil {
                Text("Your Maintenance Energy")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
//            }
        }
    }
    
    var restingHeader: some View {
        HStack {
            Image(systemName: "figure.wave")
                .matchedGeometryEffect(id: "resting-header-icon", in: namespace)
            Text("Resting Energy")
        }
    }
    
    var activeHeader: some View {
        HStack {
            Image(systemName: "figure.walk.motion")
                .matchedGeometryEffect(id: "active-header-icon", in: namespace)
            Text("Active Energy")
        }
    }
    
    //TODO: Make these changes
    /// [ ] Have a section for total with matched geometries moving the labels for the components to their sections (and the headers)
    /// [ ] Include a control that lets us switch between both views
    ///     [ ] Maybe have a button on the total itself that expands and collapses it, so when expanded it doesn't show the components inside it, they get moved away to their sections
    
    var formulaSection: some View {
        var topSection: some View {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "function")
                        .foregroundColor(.secondary)
                    Text("Calculated")
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(Color(.tertiaryLabel))
                        .imageScale(.small)
                }
                Spacer()
                HStack {
                    Text("2,024")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                    Text("kcal")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 15)
        }
        
        var formulaRow: some View {
            HStack {
                HStack {
                    Text("Using")
                        .foregroundColor(.secondary)
                    PickerLabel("Katch-McArdle")
                    Text("equation")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
        
        var flowView: some View {
            func label(_ prefix: String, _ string: String) -> some View {
                var backgroundColor: Color {
                    return colorScheme == .light ? Color(hex: "e8e9ea") : Color(hex: "434447")
                }
                return PickerLabel(
                    string,
                    prefix: prefix,
                    systemImage: useHealthAppData ? nil : "chevron.right",
//                    imageColor: <#T##Color#>,
                    backgroundColor:  useHealthAppData ? Color(.systemGroupedBackground) : backgroundColor,
                    foregroundColor: useHealthAppData ? Color(.secondaryLabel) : Color.primary,
                    prefixColor: useHealthAppData ? Color(.tertiaryLabel) : Color.secondary,
//                    imageScale: <#T##Image.Scale#>,
                    infiniteMaxHeight: false
                )
            }
            
            return FlowView(alignment: .center, spacing: 10, padding: 15) {
                ZStack {
                    Capsule(style: .continuous)
                        .foregroundColor(Color(.clear))
                    HStack(spacing: 5) {
                        Text("with")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .frame(height: 25)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                }
                .fixedSize(horizontal: true, vertical: true)
                Menu {
                    Picker(selection: .constant(true), label: EmptyView()) {
                        Text("Male").tag(true)
                        Text("Female").tag(false)
                    }
                } label: {
                    label("sex", "male")
                }
                Button {
                    path.append(.fatPercentageForm)
                } label: {
                    label("fat", "29 %")
                }
                Button {
                    path.append(.weightForm)
                } label: {
                    label("weight", "93.55 kg")
                }
                Button {
                    path.append(.heightForm)
                } label: {
                    label("height", "177 cm")
                }
            }
            .padding(.bottom, 5)
        }
        
        let useHealthAppDataBinding = Binding<Bool>(
            get: { useHealthAppData },
            set: { newValue in
                withAnimation {
                    useHealthAppData = newValue
                }
            }
        )
        return FormStyledSection(header: restingHeader, horizontalPadding: 0, verticalPadding: 0) {
            VStack {
                topSection
                formulaRow
                Divider()
                    .frame(width: 300)
                    .padding(.vertical, 5)
                flowView
                Divider()
                    .frame(width: 300)
                    .padding(.vertical, 5)
                HStack {
                    Toggle(isOn: useHealthAppDataBinding) {
                        HStack {
                            appleHealthSymbol
                            Text("\(useHealthAppData ? "Using " : "Use") Health App Data")
                        }
                    }
                    .toggleStyle(.button)
//                    Spacer()
                }
//                .padding(.leading)
            }
            .padding(.bottom)
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
        }
    }
    
    var formulaSectionNew: some View {
        
        
        let useHealthAppDataBinding = Binding<Bool>(
            get: { useHealthAppData },
            set: { newValue in
                withAnimation {
                    useHealthAppData = newValue
                }
            }
        )
        var useHealthAppToggle: some View {
            Toggle(isOn: useHealthAppDataBinding) {
                HStack {
                    appleHealthSymbol
                        .matchedGeometryEffect(id: "resting-health-icon", in: namespace)
                    Text("Sync\(useHealthAppData ? "ed" : "") with Health App")
                }
            }
            .toggleStyle(.button)
        }
        
        var topSection: some View {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "function")
                        .foregroundColor(.secondary)
                    Text("Calculated")
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(Color(.tertiaryLabel))
                        .imageScale(.small)
                }
                Spacer()
                //                useHealthAppToggle
            }
            .padding(.horizontal, 17)
        }
        
        var formulaRow: some View {
            HStack {
                HStack {
                    Text("Using")
                        .foregroundColor(.secondary)
                    PickerLabel("Katch-McArdle")
                    Text("equation")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
        
        var flowView: some View {
            func label(_ prefix: String, _ string: String) -> some View {
                var backgroundColor: Color {
                    return colorScheme == .light ? Color(hex: "e8e9ea") : Color(hex: "434447")
                }
                return PickerLabel(
                    string,
                    prefix: prefix,
                    systemImage: useHealthAppData ? nil : "chevron.right",
                    //                    imageColor: <#T##Color#>,
                    backgroundColor:  useHealthAppData ? Color(.systemGroupedBackground) : backgroundColor,
                    foregroundColor: useHealthAppData ? Color(.secondaryLabel) : Color.primary,
                    prefixColor: useHealthAppData ? Color(.tertiaryLabel) : Color.secondary,
                    //                    imageScale: <#T##Image.Scale#>,
                    infiniteMaxHeight: false
                )
            }
            
            return FlowView(alignment: .center, spacing: 10, padding: 17) {
                ZStack {
                    Capsule(style: .continuous)
                        .foregroundColor(Color(.clear))
                    HStack(spacing: 5) {
                        Text("with")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .frame(height: 25)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                }
                .fixedSize(horizontal: true, vertical: true)
                Menu {
                    Picker(selection: .constant(true), label: EmptyView()) {
                        Text("Male").tag(true)
                        Text("Female").tag(false)
                    }
                } label: {
                    label("sex", "male")
                }
                Button {
                    path.append(.fatPercentageForm)
                } label: {
                    label("fat", "29 %")
                }
                Button {
                    path.append(.weightForm)
                } label: {
                    label("weight", "93.55 kg")
                }
                Button {
                    path.append(.heightForm)
                } label: {
                    label("height", "177 cm")
                }
            }
            .padding(.bottom, 5)
        }
        
        return Group {
            VStack(spacing: 7) {
                restingHeader
                    .textCase(.uppercase)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                VStack {
                    topSection
                    formulaRow
                    Divider()
                        .frame(width: 300)
                        .padding(.vertical, 5)
                    flowView
                    useHealthAppToggle
                        .padding(.bottom)
                    HStack {
                        Spacer()
                        Text("2,024")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .matchedGeometryEffect(id: "resting", in: namespace)
                        Text("kcal")
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 0)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.secondarySystemGroupedBackground))
                        .matchedGeometryEffect(id: "resting-bg", in: namespace)
                )
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    
    var maintenanceSection: some View {
        return Group {
            VStack(spacing: 7) {
                HStack {
                    Image(systemName: "flame.fill")
                        .matchedGeometryEffect(id: "maintenance-header-icon", in: namespace)
                    Text("Maintenance Energy")
                }
                .textCase(.uppercase)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color(.secondaryLabel))
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                VStack {
                    HStack {
                        Text("3,204")
                            .fixedSize(horizontal: true, vertical: false)
                            .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                            .matchedGeometryEffect(id: "maintenance", in: namespace)
                        Text("kcal")
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 0)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.secondarySystemGroupedBackground))
                        .matchedGeometryEffect(id: "maintenance-bg", in: namespace)
                )
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    var arrowSection: some View {
        HStack {
            ZStack {
                Text("3,204")
                    .foregroundColor(.primary)
                    .font(.system(.title3, design: .default, weight: .bold))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color(.secondarySystemGroupedBackground))
                    )
                    .opacity(0)
                Image(systemName: "arrow.down")
                    .foregroundColor(Color(.quaternaryLabel))
                    .fontWeight(.light)
                    .font(.largeTitle)
            }
            Text("=")
                .font(.title)
                .foregroundColor(Color(.quaternaryLabel))
                .opacity(0)
            Text("2,204")
                .font(.system(.title3, design: .default, weight: .regular))
                .foregroundColor(.primary)
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color(.secondarySystemGroupedBackground))
                    }
                )
                .opacity(0)
            Text("+")
                .font(.title)
                .foregroundColor(Color(.quaternaryLabel))
                .opacity(0)
            Text("1,428")
                .font(.system(.title3, design: .default, weight: .regular))
                .foregroundColor(.primary)
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color(.secondarySystemGroupedBackground))
                )
                .opacity(0)
        }
        .padding(.horizontal, 17)
    }
    
    func toggleEditState() {
        if isEditing {
            transitionToCollapsedState()
        } else {
            transitionToEditState()
        }
    }
    
    func transitionToCollapsedState() {
        Haptics.successFeedback()
        withAnimation {
            isEditing = false
            presentationDetent = .medium
        }
    }
    
    func transitionToEditState() {
        Haptics.feedback(style: .rigid)
        withAnimation {
            isEditing = true
            presentationDetent = .large
        }
    }
    var mainSection: some View {
        Button {
            transitionToEditState()
        } label: {
            HStack {
                VStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .matchedGeometryEffect(id: "maintenance-header-icon", in: namespace)
                        .foregroundColor(Color(.tertiaryLabel))
                        .imageScale(.medium)
                    Text("3,204")
                        .foregroundColor(.primary)
                        .matchedGeometryEffect(id: "maintenance", in: namespace)
                        .font(.system(.title3, design: .default, weight: .bold))
                        .monospacedDigit()
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color(.secondarySystemGroupedBackground))
                                .matchedGeometryEffect(id: "maintenance-bg", in: namespace)
                        )
                }
                VStack(spacing: 10) {
                    Image(systemName: "figure.wave")
                        .foregroundColor(Color(.tertiaryLabel))
                        .imageScale(.medium)
                        .opacity(0)
                    Text("=")
                        .matchedGeometryEffect(id: "equals", in: namespace)
                        .font(.title)
                        .foregroundColor(Color(.quaternaryLabel))
                }
                VStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "figure.wave")
                            .matchedGeometryEffect(id: "resting-header-icon", in: namespace)
                            .foregroundColor(Color(.tertiaryLabel))
                            .imageScale(.medium)
                        appleHealthSymbol
                            .imageScale(.small)
                            .matchedGeometryEffect(id: "resting-health-icon", in: namespace)
                    }
                    Text("2,024")
                        .matchedGeometryEffect(id: "resting", in: namespace)
                        .fixedSize(horizontal: true, vertical: false)
                        .font(.system(.title3, design: .default, weight: .regular))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(Color(.secondarySystemGroupedBackground))
                                    .matchedGeometryEffect(id: "resting-bg", in: namespace)
                            }
                        )
                }
                VStack(spacing: 10) {
                    Image(systemName: "figure.wave")
                        .foregroundColor(Color(.tertiaryLabel))
                        .imageScale(.medium)
                        .opacity(0)
                    Text("+")
                        .matchedGeometryEffect(id: "plus", in: namespace)
                        .font(.title)
                        .foregroundColor(Color(.quaternaryLabel))
                }
                VStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "figure.walk.motion")
                            .matchedGeometryEffect(id: "active-header-icon", in: namespace)
                            .foregroundColor(Color(.tertiaryLabel))
                            .imageScale(.medium)
                        appleHealthSymbol
                            .matchedGeometryEffect(id: "active-health-icon", in: namespace)
                            .imageScale(.small)
                    }
                    Text("1,428")
                        .matchedGeometryEffect(id: "active", in: namespace)
                        .font(.system(.title3, design: .default, weight: .regular))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color(.secondarySystemGroupedBackground))
                                .matchedGeometryEffect(id: "active-bg", in: namespace)
                        )
                }
            }
            .padding(.horizontal, 17)
        }
    }
    
    var activeHealthSection: some View {
        var content: some View {
            VStack(spacing: 5) {
                HStack {
                    HStack(spacing: 5) {
                        appleHealthSymbol
                            .matchedGeometryEffect(id: "active-health-icon", in: namespace)
                        Text("Health App")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(Color(.tertiaryLabel))
                            .imageScale(.small)
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    HStack {
                        Text("Use")
                            .foregroundColor(.secondary)
                        PickerLabel("previous day's value")
                    }
                    Spacer()
                }
                .padding(.top)
                .padding(.bottom)
                HStack {
                    Spacer()
                    Text("1,428")
                        .matchedGeometryEffect(id: "active", in: namespace)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                    Text("kcal")
                        .foregroundColor(.secondary)
                }
            }
        }
        
        return VStack(spacing: 7) {
            activeHeader
                .foregroundColor(Color(.secondaryLabel))
                .font(.footnote)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            content
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 17)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.secondarySystemGroupedBackground))
                        .matchedGeometryEffect(id: "active-bg", in: namespace)
                )
                .padding(.bottom, 10)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }    
}

public struct TDEEFormPreview: View {
    public init() { }
    public var body: some View {
        TDEEForm()
    }
}

struct TDEEForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    TDEEFormPreview()
                }
        }
    }
}

struct LeftAlignedFlowLayout: Layout {
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let height = calculateRects(origin: CGPoint.zero, width: proposal.width ?? 0, subviews: subviews).last?.maxY ?? 0
        return CGSize(width: proposal.width ?? 0, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        
        calculateRects(origin: bounds.origin, width: bounds.width, subviews: subviews).enumerated().forEach { index, rect in
            let sizeProposal = ProposedViewSize(rect.size)
            subviews[index].place(at: rect.origin, proposal: sizeProposal)
        }
    }
    
    func calculateRects(origin: CGPoint, width: CGFloat, subviews: Subviews) -> [CGRect] {
        
        var nextPosition = origin // was CGPoint.zero
        return subviews.indices.map { index in
            
            let size = subviews[index].sizeThatFits(.unspecified)
            
            var nextHSpacing: CGFloat = 0
            var previousVSpacing: CGFloat = 0
            
            if index > subviews.startIndex {
                let previousIndex = index.advanced(by: -1)
                previousVSpacing = subviews[previousIndex].spacing.distance(to: subviews[index].spacing, along: .vertical)
            }
            
            if index < subviews.endIndex.advanced(by: -1) {
                let nextIndex = index.advanced(by: 1)
                nextHSpacing = subviews[index].spacing.distance(to: subviews[nextIndex].spacing, along: .horizontal)
            }
            
            if nextPosition.x + nextHSpacing + size.width > width {
                nextPosition.x = 0
                nextPosition.y += size.height + previousVSpacing
            }
            
            let thisPosition = nextPosition
            print(thisPosition)
            nextPosition.x += nextHSpacing + size.width
            return CGRect(origin: thisPosition, size: size)
        }
    }
}
