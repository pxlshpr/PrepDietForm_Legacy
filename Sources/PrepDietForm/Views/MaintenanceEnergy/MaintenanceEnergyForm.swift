import SwiftUI
import SwiftUISugar
import SwiftHaptics
import HealthKit
import PrepDataTypes

struct MaintenanceEnergyForm: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var manuallyEnterBMR: Bool = false
    @State var manuallyEnterTDEE: Bool = false
    @State var applyActivityScaleFactor: Bool = true
    @State var manuallyEnteredBMR: String = ""
    @State var manuallyEnteredTDEE: String = ""
    
    @State var syncHealthKitMeasurements: Bool = false
    @State var syncHealthKitActiveEnergy: Bool = true
    
    @State var equation: BMREquation = .mifflinStJeor
    @State var activityLevel: BMRActivityLevel = .moderatelyActive
    @State var biologicalSex: HKBiologicalSex = .male
    @State var weightUnit: WeightUnit = .kg
    @State var heightUnit: HeightUnit = .cm
    
    @State var weightDouble: Double? = nil
    @State var weightString: String = ""

    @State var heightDouble: Double? = nil
    @State var heightString: String = ""

    @State var heightSecondaryDouble: Double? = nil
    @State var heightSecondaryString: String = ""

    @State var hasAppeared = false
    
    @ViewBuilder
    var body: some View {
        if hasAppeared {
            navigationView
        } else {
            Color(.systemGroupedBackground)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        withAnimation {
                            hasAppeared = true
                        }
                    }
                }
        }
    }

    var navigationView: some View {
        NavigationView {
            Form {
                manualEntrySection
                if !manuallyEnterTDEE {
                    bmrSection
                    bodyMeasurementsSection
                    tdeeSection
                }
                activeEnergySection
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("2,250 kcal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { principalContent }
            .toolbar { trailingContent }
        }
    }
    
    var trailingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
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
            Text("Your Maintenance Calories")
//                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    var bmrHeader: some View {
        HStack {
            Text("BMR")
            Text("•")
                .foregroundColor(Color(.quaternaryLabel))
            Text("Basal Metabolic Rate")
                .foregroundColor(Color(.tertiaryLabel))
        }
    }

    var tdeeHeader: some View {
        HStack {
            Text("Activity Level")
        }
    }

    var bodyMeasurementsSection: some View {
        @ViewBuilder
        var footer: some View {
            if syncHealthKitMeasurements {
                Text("Your measurements from HealthKit will be kept in sync to keep your maintenance calories up-to-date.")
            }
        }
        
        var header: some View {
            Text("Body Measurements")
        }

        return Section(header: header, footer: footer) {
            Toggle(isOn: $syncHealthKitMeasurements) {
                HStack {
                    Image(systemName: "heart.fill")
                        .renderingMode(.original)
                    Text("Sync with HealthKit")
                }
            }
            biologicalSexField
            weightField
            heightField
        }
    }
    
    var weightField: some View {
        var unitPicker: some View {
            Menu {
                Picker(selection: $weightUnit, label: EmptyView()) {
                    ForEach([WeightUnit.kg, WeightUnit.lb], id: \.self) {
                        Text($0.pickerDescription + "s").tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(weightUnit.shortDescription)
                    if !syncHealthKitMeasurements {
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                }
                .foregroundColor(.accentColor)
                .fixedSize(horizontal: true, vertical: true)
                .animation(.none, value: weightUnit)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
            .disabled(syncHealthKitMeasurements)
        }
        
        let weightBinding = Binding<String>(
            get: {
                weightString
            },
            set: { newValue in
                guard !newValue.isEmpty else {
                    weightDouble = nil
                    weightString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.weightDouble = double
                withAnimation {
                    self.weightString = newValue
                }
            }
        )
        
        var textField: some View {
            TextField("weight in", text: weightBinding)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .disabled(syncHealthKitMeasurements)
        }
        
        return HStack {
            Text("Weight")
            Spacer()
            textField
            unitPicker
        }
    }
    
    var heightField: some View {
        var unitPicker: some View {
            Menu {
                Picker(selection: $heightUnit, label: EmptyView()) {
                    ForEach(HeightUnit.allCases, id: \.self) {
                        Text($0.description).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(heightUnit.shortDescription)
                    if !syncHealthKitMeasurements {
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                }
                .foregroundColor(.accentColor)
                .fixedSize(horizontal: true, vertical: true)
                .animation(.none, value: heightUnit)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
            .disabled(syncHealthKitMeasurements)
        }
        
        let heightBinding = Binding<String>(
            get: {
                heightString
            },
            set: { newValue in
                guard !newValue.isEmpty else {
                    heightDouble = nil
                    heightString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.heightDouble = double
                withAnimation {
                    self.heightString = newValue
                }
            }
        )
        
        let heightSecondaryBinding = Binding<String>(
            get: {
                heightSecondaryString
            },
            set: { newValue in
                guard !newValue.isEmpty else {
                    heightSecondaryDouble = nil
                    heightSecondaryString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.heightSecondaryDouble = double
                withAnimation {
                    self.heightSecondaryString = newValue
                }
            }
        )
        
        var textField: some View {
            TextField("height in", text: heightBinding)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .disabled(syncHealthKitMeasurements)
        }

        func secondaryTextField(_ placeholder: String) -> some View {
            TextField(placeholder, text: heightSecondaryBinding)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .disabled(syncHealthKitMeasurements)
                .fixedSize(horizontal: true, vertical: false)
        }
        
        func secondaryUnit(_ string: String) -> some View {
            HStack(spacing: 5) {
                Text(string)
            }
            .foregroundColor(.secondary)
        }

        return HStack {
            Text("Height")
            Spacer()
            textField
            unitPicker
            if heightUnit == .ft {
                secondaryTextField("in")
                secondaryUnit("in")
            }
            if heightUnit == .m {
                secondaryTextField("cm")
                secondaryUnit("cm")
            }
        }
    }
    var biologicalSexField: some View {
        var picker: some View {
            Menu {
                Picker(selection: $biologicalSex, label: EmptyView()) {
                    Text("female").tag(HKBiologicalSex.female)
                    Text("male").tag(HKBiologicalSex.male)
                }
            } label: {
                HStack(spacing: 5) {
                    Text(biologicalSex.description.lowercased())
                    if !syncHealthKitMeasurements {
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                }
                .foregroundColor(.accentColor)
                .animation(.none, value: biologicalSex)
                .fixedSize(horizontal: true, vertical: true)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
            .disabled(syncHealthKitMeasurements)
        }

        return HStack {
            Text("Biological Sex")
            Spacer()
            picker
        }
    }
    
    var bmrSection: some View {
        Section(header: bmrHeader) {
            if manuallyEnterBMR {
                TextField("Enter BMR in kcal", text: $manuallyEnteredBMR)
            } else {
                Picker(selection: $equation) {
                    ForEach(BMREquation.allCases, id: \.self) {
                        Text($0.description).tag($0)
                    }
                } label: {
                    Text("Equation")
                }
            }
            Toggle(isOn: $manuallyEnterBMR) {
                VStack(alignment: .leading) {
                    Text("Enter Manually")
                }
            }
        }
    }
    
    var tdeeSection: some View {
        Section(header: tdeeHeader) {
            Toggle(isOn: $applyActivityScaleFactor) {
                VStack(alignment: .leading) {
                    Text("Apply Activity Scale Factor")
                }
            }
            if applyActivityScaleFactor {
                Picker(selection: $activityLevel) {
                    ForEach(BMRActivityLevel.allCases, id: \.self) {
                        Text($0.description).tag($0)
                    }
                } label: {
                    Text("Activity Level")
                }
            }
        }
    }
    
    var activeEnergySection: some View {
        var header: some View {
            Text("Active Energy")
        }
        
        @ViewBuilder
        var footer: some View {
            if syncHealthKitActiveEnergy {
                Text("Your daily active energy from HealthKit will be added to your maintenance calories whenever available.")
            }
        }
        return Section(header: header, footer: footer) {
            Toggle(isOn: $syncHealthKitActiveEnergy) {
                HStack {
                    Image(systemName: "heart.fill")
                        .renderingMode(.original)
                    Text("Sync with HealthKit")
                }
            }
        }
    }
    
    var manualEntrySection: some View {
        Section {
            Toggle(isOn: $manuallyEnterTDEE) {
                VStack(alignment: .leading) {
                    Text("Enter Manually")
                }
            }
            if manuallyEnterTDEE {
                TextField("Enter TDEE in kcal", text: $manuallyEnteredTDEE)
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


public struct MaintenanceEnergySettingsPreview: View {
    public init() { }
    public var body: some View {
        MaintenanceEnergyForm()
    }
}

struct MaintenanceEnergySettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    MaintenanceEnergySettingsPreview()
                        .presentationDetents([.height(600), .large])
                        .presentationDragIndicator(.hidden)
                }
        }
    }
}
