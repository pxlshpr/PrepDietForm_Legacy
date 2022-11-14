import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes
import HealthKit

enum HealthKitEnergyPeriodOption: CaseIterable {
    case previousDay
    case average
    
    var menuDescription: String {
        switch self {
        case .previousDay:
            return "Day Before"
        case .average:
            return "Past Average"
        }
    }
    var pickerDescription: String {
        switch self {
        case .previousDay:
            return "Day Before"
        case .average:
            return "Average over"
        }
    }
}

struct TDEEForm: View {
    
    @Environment(\.dismiss) var dismiss

    @State var showingAdaptiveCorrectionInfo = false

//    @State var tdeeSource: TDEESource = .formula(.mifflinStJeor, activityLevel: .moderatelyActive)
    @State var tdeeSource: TDEESourceOption = .userEntered

    @State var syncHealthKitMeasurements: Bool = false
    @State var useHealthActiveEnergy: Bool = false
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

    var navigationView: some View {
        NavigationView {
            Form {
                sourceSection
                if tdeeSource == .healthKit {
                    healthSection
                }
                if tdeeSource != .healthKit {
                    restingEnergySection
                }
                if tdeeSource != .healthKit {
                    activeEnergySection
                }
                adaptiveCorrectionSection
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar { principalContent }
            .toolbar { trailingContent }
            .toolbar { leadingContent }
            .interactiveDismissDisabled(valuesHaveChanged)
            .onChange(of: syncHealthKitMeasurements, perform: syncHealthKitMeasurementsChanged)
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
            if maintenanceEnergy != nil {
                Text("Your Maintenance Energy")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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

