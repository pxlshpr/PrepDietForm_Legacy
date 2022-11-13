import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes
import HealthKit

struct TDEEForm: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var syncHealthKitMeasurements: Bool = false
    @State var syncHealthKitActiveEnergy: Bool = false
    @State var applyActivityScaleFactor: Bool = true

    @State var bmrEquation: BMREquation = .mifflinStJeor
    @State var activityLevel: BMRActivityLevel = .moderatelyActive
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

    @State var heightSecondaryDouble: Double? = nil
    @State var heightSecondaryString: String = ""

    @State var hasAppeared = false
    
    @State var valuesHaveChanged: Bool = true
    
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
                if !manualTDEE {
                    bmrSection
                    bodyMeasurementsSection
                }
                activeEnergySection
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("2,250 kcal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { principalContent }
            .toolbar { trailingContent }
            .toolbar { leadingContent }
            .interactiveDismissDisabled(valuesHaveChanged)
            .onChange(of: syncHealthKitMeasurements, perform: syncHealthKitMeasurementsChanged)
        }
    }
    
    func syncHealthKitMeasurementsChanged(to newValue: Bool) {
        guard newValue == true else { return }
        Task {
            guard await HealthKitManager.shared.requestPermission() else {
                print("Couldn't get permission")
                return
            }
            
            let (weight, weightDate) = await HealthKitManager.shared.weight()
            await MainActor.run {
                self.weightDouble = weight
                self.weightString = weight.cleanAmount
                self.weightDate = weightDate
            }
        }
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
    
    func blankViewAppeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation {
                hasAppeared = true
            }
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
