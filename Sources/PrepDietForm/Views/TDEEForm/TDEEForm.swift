import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes
import HealthKit

struct TDEEForm: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State var showingAdaptiveCorrectionInfo = false

//    @State var tdeeSource: TDEESource = .formula(.mifflinStJeor, activityLevel: .moderatelyActive)
    @State var restingEnergySource: RestingEnergySourceOption = .healthApp
    @State var activeEnergySource: ActiveEnergySourceOption = .healthApp

    @State var syncHealthKitMeasurements: Bool = false
    @State var applyActivityScaleFactor: Bool = true

    @State var bmrEquation: TDEEFormula = .mifflinStJeor
    @State var activityLevel: ActivityLevel = .moderatelyActive
    @State var biologicalSex: HKBiologicalSex = .male
    @State var weightUnit: WeightUnit = .kg
    @State var heightUnit: HeightUnit = .cm

    @State var manualBMR: Bool = false
    @State var bmrUnit: EnergyUnit = .kcal
    @State var bmrDouble: Double? = nil
    @State var bmrString: String = ""

    @State var manualTDEE: Bool = false
    @State var tdeeUnit: EnergyUnit = .kcal
    @State var tdeeDouble: Double? = nil
    @State var tdeeString: String = ""

    @State var weightDouble: Double? = nil
    @State var weightString: String = ""
    @State var weightDate: Date? = nil

    @State var heightDouble: Double? = nil
    @State var heightString: String = ""
    @State var heightDate: Date? = nil

    @State var heightSecondaryDouble: Double? = nil
    @State var heightSecondaryString: String = ""

    @State var hasAppeared = false
    
    @State var valuesHaveChanged: Bool = true
    
    @State var healthRestingEnergy: Double? = nil
    @State var healthActiveEnergy: Double? = nil
    
    @State var healthEnergyPeriod: HealthKitEnergyPeriodOption = .previousDay
    @State var healthEnergyPeriodInterval: DateComponents = DateComponents(day: 1)
    
    @ViewBuilder
    var body: some View {
        if hasAppeared {
            navigationView
        } else {
            Color(.systemGroupedBackground)
                .onAppear(perform: blankViewAppeared)
        }
    }

    enum Route: Hashable {
        case healthAppPeriod
        case fatPercentageForm
        case weightForm
        case heightForm
    }
    
//    @State var path: [Route] = [.healthAppPeriod]
    @State var path: [Route] = []

    var navigationView: some View {
        NavigationStack(path: $path) {
//            legacyForm
            formFormula
//            formHealth
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Maintenance Calories")
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { principalContent }
//            .toolbar { trailingContent }
            .toolbar { leadingContent }
//            .interactiveDismissDisabled(valuesHaveChanged)
            .onChange(of: syncHealthKitMeasurements, perform: syncHealthKitMeasurementsChanged)
            .navigationDestination(for: Route.self, destination: navigationDestination)
            .task { await initialTask() }
        }
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
        ToolbarItem(placement: .navigationBarTrailing) {
            if valuesHaveChanged {
                Button {
                    Haptics.successFeedback()
                    dismiss()
                } label: {
                    Text("Save")
                        .bold()
//                    Image(systemName: "checkmark")
                }
            }
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
    
    var legacyForm: some View {
        Form {
//                restingEnergySection
            activeEnergySection
//                adaptiveCorrectionSection
        }
    }
    
    var restingHeader: some View {
        HStack {
            Image(systemName: "figure.mind.and.body")
            Text("Resting Energy")
        }
    }
    
    var activeHeader: some View {
        HStack {
            Image(systemName: "figure.walk.motion")
            Text("Active Energy")
        }
    }
    
    //TODO: Make these changes
    /// [ ] Have a section for total with matched geometries moving the labels for the components to their sections (and the headers)
    /// [ ] Include a control that lets us switch between both views
    ///     [ ] Maybe have a button on the total itself that expands and collapses it, so when expanded it doesn't show the components inside it, they get moved away to their sections

    @State var useHealthAppData = false
    
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
                    Text("Sync with Health App")
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
    
        return FormStyledSection(header: restingHeader, horizontalPadding: 0) {
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
                    Text("kcal")
                        .foregroundColor(.secondary)
                }
                .padding(.trailing)
            }
        }
    }
    var formFormula: some View {
        FormStyledScrollView {
            mainSection
                .padding(.top, 5)
                .padding(.bottom, 10)
            HStack(alignment: .firstTextBaseline) {
                appleHealthSymbol
                    .font(.caption2)
                Text("These components will be continuously updated as new data comes in from the Health App.")
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 17)
//            formulaSectionNew
//            activeHealthSection
//            restingHealthSection
        }
    }
    
    var mainSection: some View {
        HStack {
            VStack(spacing: 10) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.secondary)
                    .imageScale(.medium)
                Text("3,204")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color(.secondarySystemGroupedBackground))
                    )
            }
            VStack(spacing: 10) {
                Image(systemName: "figure.mind.and.body")
                    .foregroundColor(Color(.tertiaryLabel))
                    .imageScale(.medium)
                    .opacity(0)
                Text("=")
                    .font(.title)
                    .foregroundColor(Color(.quaternaryLabel))
            }
            VStack(spacing: 10) {
                HStack(spacing: 3) {
                    Image(systemName: "figure.mind.and.body")
                        .foregroundColor(Color(.tertiaryLabel))
                        .imageScale(.medium)
                    appleHealthSymbol
                        .imageScale(.small)
                }
                Text("1,776")
                    .font(.system(.title3, design: .rounded, weight: .regular))
                    .monospacedDigit()
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color(.secondarySystemGroupedBackground))
//                            VStack {
//                                HStack {
//                                    Spacer()
//                                    appleHealthSymbol
//                                        .imageScale(.small)
//                                        .padding(.trailing, 5)
//                                        .padding(.leading, 5)
//                                }
//                                Spacer()
//                            }
                        }
                    )
            }
            VStack(spacing: 10) {
                Image(systemName: "figure.mind.and.body")
                    .foregroundColor(Color(.tertiaryLabel))
                    .imageScale(.medium)
                    .opacity(0)
                Text("+")
                    .font(.title)
                    .foregroundColor(Color(.quaternaryLabel))
            }
            VStack(spacing: 10) {
                HStack(spacing: 3) {
                    Image(systemName: "figure.walk.motion")
                        .foregroundColor(Color(.tertiaryLabel))
                        .imageScale(.medium)
                    appleHealthSymbol
                        .imageScale(.small)
                }
                Text("1,428")
                    .font(.system(.title3, design: .rounded, weight: .regular))
                    .monospacedDigit()
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color(.secondarySystemGroupedBackground))
                    )
            }
        }
        .padding(.horizontal, 17)
    }
    
    var restingHealthSection: some View {
        FormStyledSection(header: restingHeader) {
            VStack(spacing: 5) {
                HStack {
                    HStack(spacing: 5) {
                        appleHealthSymbol
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
                        PickerLabel("daily average of")
                    }
                    Spacer()
                }
                .padding(.top)
                HStack {
                    Spacer()
                    HStack {
                        Text("The past")
                            .foregroundColor(Color(.secondaryLabel))
                        PickerLabel("2")
                        PickerLabel("weeks")
                    }
                    Spacer()
                }
                .padding(.bottom)
                HStack {
                    Spacer()
                    Text("2,024")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                    Text("kcal")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    var activeHealthSection: some View {
        FormStyledSection(header: activeHeader) {
            VStack(spacing: 5) {
                HStack {
                    HStack(spacing: 5) {
                        appleHealthSymbol
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
                    Text("1,203")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                    Text("kcal")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    var formHealth: some View {
        FormStyledScrollView {
            restingHealthSection
            activeHealthSection
        }
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
                        .presentationDetents([.height(230), .large])
                        .presentationDragIndicator(.hidden)
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
