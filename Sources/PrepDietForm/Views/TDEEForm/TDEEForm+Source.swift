import SwiftUI
import SwiftHaptics
import PrepDataTypes

extension TDEEForm {
    var manualEntrySection: some View {
        
        var sourcePicker: some View {
            let tdeeSourceBinding = Binding<TDEESourceOption>(
                get: { tdeeSource },
                set: { newValue in
                    Haptics.feedback(style: .soft)
                    withAnimation {
                        tdeeSource = newValue
                    }
                    refreshSource.toggle()
                }
            )
            
            return Menu {
                Picker(selection: $tdeeSource, label: EmptyView()) {
                    ForEach(TDEESourceOption.allCases, id: \.self) {
                        Label($0.menuDescription, systemImage: $0.systemImage).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(tdeeSource.pickerDescription)
                        .fixedSize(horizontal: true, vertical: true)
                        .multilineTextAlignment(.trailing)
                        .id(refreshSource)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .foregroundColor(.secondary)
                .animation(.none, value: tdeeSource)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
        
        var formulaPicker: some View {
            Menu {
                Picker(selection: $bmrEquation, label: EmptyView()) {
                    ForEach(TDEEFormula.allCases, id: \.self) {
                        Text($0.description).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(bmrEquation.description)
                        .multilineTextAlignment(.trailing)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .foregroundColor(.secondary)
                .animation(.none, value: bmrEquation)
                .fixedSize(horizontal: true, vertical: true)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
        
        var tdeeTextField: some View {
            var unitPicker: some View {
                Menu {
                    Picker(selection: $tdeeUnit, label: EmptyView()) {
                        ForEach(EnergyUnit.allCases, id: \.self) {
                            Text($0.shortDescription).tag($0)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(tdeeUnit.shortDescription)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundColor(.accentColor)
                    .fixedSize(horizontal: true, vertical: true)
                    .animation(.none, value: tdeeUnit)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
            }
            
            let tdeeBinding = Binding<String>(
                get: {
                    tdeeString
                },
                set: { newValue in
                    guard !newValue.isEmpty else {
                        tdeeDouble = nil
                        tdeeString = newValue
                        return
                    }
                    guard let double = Double(newValue) else {
                        return
                    }
                    tdeeDouble = double
                    withAnimation {
                        tdeeString = newValue
                    }
                }
            )
            
            var textField: some View {
                TextField("energy in", text: tdeeBinding)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            
            return HStack {
                Text("BMR")
                Spacer()
                textField
                unitPicker
            }
        }
                
        var header: some View {
            HStack {
                Text("BMR")
                Text("•")
                    .foregroundColor(Color(.quaternaryLabel))
                Text("Basal Metabolic Rate")
                    .foregroundColor(Color(.tertiaryLabel))
                    .multilineTextAlignment(.trailing)
            }
        }

        @ViewBuilder
        var footer: some View {
            if tdeeSource == .formula {
                Text("Your Resting Energy is caulcated to be 2,250 kcal.")
            }
        }
        
        var sourceField: some View {
            HStack {
                Text("Source")
                Spacer()
                sourcePicker
            }
        }
        
        var formulaField: some View {
            NavigationLink {
                Form {
                    Section {
                        HStack {
                            Text("Formula")
                            Spacer()
                            formulaPicker
                        }
                    }
                    bodyMeasurementsSection
                }
                .navigationTitle("BMR")
            } label: {
                HStack {
                    Text("Formula")
                    Spacer()
                    Text(bmrEquation.description)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
//                    formulaPicker
                }
            }
        }
        
        return Section(footer: footer) {
            sourceField
            switch tdeeSource {
            case .formula:
                formulaField
            case .userEntered:
                tdeeTextField
            default:
                EmptyView()
            }
        }
    }
}

let AppleHealthBottomColorHex = "fc2e1d"
let AppleHealthTopColorHex = "fe5fab"

var appleHealthSymbol: some View {
    Image(systemName: "heart.fill")
        .symbolRenderingMode(.palette)
        .foregroundStyle(
            .linearGradient(
                colors: [
                    Color(hex: AppleHealthTopColorHex),
                    Color(hex: AppleHealthBottomColorHex)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
}

extension TDEEForm {
    var adaptiveCorrectionSection: some View {
        
        var footer: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("A correction will be applied to your maintenance calories based on the fluctuations in your weight.")
                Button {
                    Haptics.feedback(style: .soft)
                    showingAdaptiveCorrectionInfo = true
                } label: {
                    Label("Learn More", systemImage: "info.circle")
                        .font(.footnote)
                }
                .sheet(isPresented: $showingAdaptiveCorrectionInfo) {
                    NavigationView {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 5) {
                                /// Possibly: Mention the paper by Max Wishnofsky [mentioned here](https://www.verywellfit.com/running-to-lose-weight-how-many-calories-in-a-pound-2911107). Talk about how We'll be assuming that 500 kcal/day deficit equates to about 0.45 kg (following the 1pound/week rule) and
                                Text("Talk about how resting energy calculations are very approximate, and that they are different for everyone. Mention how using a formula is also a very rough approximation and that each person has indivudal differences that can make their BMR vary quite a bit.")
                                Text("Mention how this feature will observe the fluctuations in their weight, against the food that they log — and statistically derive what their true maintenance calories are.")
                                Text("Be transparent here and show a clear diagram of what we're doing: We will place it in the following equation weeklymaintenance+food eaten = x kg. So by placing their true weight change in that equation we'll then determine what their true weekly maintenance is.")
                                Text("")
                                Text("This will hopefully account for any errors in the calculation of their TDEE (either by a formula or using data from Apple Health), and provide them with a clearer guideline of how much to eat going forward, in order to meet their weight goals.")
                                Text("Mention how in order for this to work accurately—the user would have to consistently log their food and weigh themselves at least a few times per week.")
                            }
                        }
                        .navigationTitle("How Adaptive Correction Works")
                        .navigationBarTitleDisplayMode(.inline)
                        .padding(.horizontal)
                    }
                    .presentationDetents([.medium])
                }
            }
        }
        
        return Section(footer: footer) {
            HStack {
                //TODO: Toggling this on should ask for weight permission if not already received for BMR.
                Text("Use Adaptive Correction")
                    .layoutPriority(1)
                Spacer()
                Toggle("", isOn: .constant(true))
            }
        }
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
        
        var averageIntervalTextField: some View {
            TextField("days", text: .constant(""))
                .fixedSize(horizontal: true, vertical: false)
        }
        
        var averageIntervalPicker: some View {
            Menu {
                Picker(selection: .constant((1)), label: EmptyView()) {
                    Text("days").tag(1)
                    Text("weeks").tag(2)
                    Text("months").tag(3)
                }
            } label: {
                HStack(spacing: 5) {
                    Text("days")
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .foregroundColor(.accentColor)
                .fixedSize(horizontal: true, vertical: true)
                .animation(.none, value: healthKitValuesToUse)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
        
        return Section(header: header) {
            HStack {
                Text("Data")
                Spacer()
                Menu {
                    Picker(selection: $healthKitValuesToUse, label: EmptyView()) {
                        ForEach(HealthKitValuesToUseOption.allCases, id: \.self) {
                            Text($0.menuDescription).tag($0)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(healthKitValuesToUse.pickerDescription)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundColor(.accentColor)
                    .fixedSize(horizontal: true, vertical: true)
                    .animation(.none, value: healthKitValuesToUse)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
                if healthKitValuesToUse == .average {
                    averageIntervalTextField
                    averageIntervalPicker
                }
            }
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
