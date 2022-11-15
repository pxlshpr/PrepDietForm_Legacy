import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes
import HealthKit

struct TDEEForm: View {
    
    @Environment(\.dismiss) var dismiss

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
    }
    
//    @State var path: [Route] = [.healthAppPeriod]
    @State var path: [Route] = []

    var navigationView: some View {
        NavigationStack(path: $path) {
//            legacyForm
//            formHealth
            formFormula
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Maintenance Energy")
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { principalContent }
            .toolbar { trailingContent }
            .toolbar { leadingContent }
            .interactiveDismissDisabled(valuesHaveChanged)
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
            .background(Color(.secondarySystemFill))
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
            FlowView(alignment: .center, spacing: 10) {
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
                PickerLabel("male", prefix: "sex", systemImage: "chevron.forward", infiniteMaxHeight: false)
                PickerLabel("29%", prefix: "fat", systemImage: "chevron.forward", infiniteMaxHeight: false)
                PickerLabel("93.55 kg", prefix: "weight", systemImage: "chevron.forward", infiniteMaxHeight: false)
                PickerLabel("177 cm", prefix: "height", systemImage: "chevron.forward", infiniteMaxHeight: false)
            }
            .padding(.bottom)
        }
        
        return FormStyledSection(header: restingHeader, horizontalPadding: 0, verticalPadding: 0) {
            VStack(spacing: 5) {
                topSection
                VStack {
                    formulaRow
                    Divider()
                    flowView
                }
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
        }
    }
    
    var formFormula: some View {
        FormStyledScrollView {
            formulaSection
        }
    }
    
    var formHealth: some View {
        FormStyledScrollView {
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
                        .presentationDetents([.height(600), .large])
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
