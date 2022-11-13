import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes
import HealthKit

struct TDEEForm: View {
    
    @Environment(\.dismiss) var dismiss
    
//    @State var tdeeSource: TDEESource = .formula(.mifflinStJeor, activityLevel: .moderatelyActive)
    @State var tdeeSource: TDEESourceOption = .healthKit
    
    @State var syncHealthKitMeasurements: Bool = false
    @State var syncHealthKitActiveEnergy: Bool = false
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
    
    @State var healthKitRestingEnergy: Double? = nil
    @State var healthKitActiveEnergy: Double? = nil
    
    @State var refreshSource: Bool = false
    
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
                manualEntrySection
                if tdeeSource == .healthKit {
                    healthKitSection
                }
                if tdeeSource != .healthKit {
                    activeEnergySection
                }
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
    
    var title: String {
        guard let healthKitActiveEnergy, let healthKitRestingEnergy else {
            return "Maintenace Calories"
        }
        let total = healthKitActiveEnergy + healthKitRestingEnergy
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let number = NSNumber(value: Int(total))
        guard let formatted = numberFormatter.string(from: number) else {
            return "Maintenance Calories"
        }
        return formatted + " kcal"
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
            Text("Your Maintenance \(tdeeUnit == .kcal ? "Calories" : "Energy")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

extension HKBiologicalSex {
    var description: String {
        switch self {
        case .female:
            return "Female"
        case .male:
            return "Male"
        case .other:
            return "Other"
        case .notSet:
            return "Not Set"
        default:
            return "Unknown"
        }
    }
}

extension HeightUnit {
    var description: String {
        switch self {
        case .m:
            return "meters"
        case .cm:
            return "centimeters"
        case .ft:
            return "feet"
        }
    }
    
    var shortDescription: String {
        switch self {
        case .cm:
            return "cm"
        case .ft:
            return "ft"
        case .m:
            return "m"
        }
    }
}

public struct TDEEFormPreview: View {
    public init() { }
    public var body: some View {
        TDEEForm()
    }
}

extension TDEEForm {
    

    var healthKitSection: some View {
        var header: some View {
            HStack {
                appleHealthSymbol
                Text("Apple Health")
            }
        }
        return Section(header: header) {
            HStack {
                Text("Resting Energy")
                Spacer()
                if let healthKitRestingEnergy {
                    Text(healthKitRestingEnergy.cleanAmount)
                        .foregroundColor(.secondary)
                    Text("kcal")
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
            HStack {
                Text("Active Energy")
                Spacer()
                if let healthKitActiveEnergy {
                    Text(healthKitActiveEnergy.cleanAmount)
                        .foregroundColor(.secondary)
                    Text("kcal")
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
            .task {
                guard let restingEnergy = await HealthKitManager.shared.getLatestRestingEnergy() else {
                    return
                }
                await MainActor.run {
                    self.healthKitRestingEnergy = restingEnergy
                }

                guard let activeEnergy = await HealthKitManager.shared.getLatestActiveEnergy() else {
                    return
                }
                await MainActor.run {
                    self.healthKitActiveEnergy = activeEnergy
                }
            }
        }
    }
}
