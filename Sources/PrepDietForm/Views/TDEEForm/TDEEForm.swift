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
            form
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

    var form: some View {
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

