import SwiftUI
import SwiftHaptics

extension TDEEForm {

    var healthActiveEnergyField: some View {
        HStack {
            Text("Active Energy")
            Spacer()
            if let healthActiveEnergy {
                Text(healthActiveEnergy.formattedEnergy)
                    .monospacedDigit()
                    .foregroundColor(.secondary)
                Text("kcal")
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
    }
    
    var healthPeriodField: some View {
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
                .foregroundColor(.secondary)
                .fixedSize(horizontal: true, vertical: true)
                .animation(.none, value: healthEnergyPeriod)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
        
        var periodPicker: some View {
            Menu {
                Picker(selection: $healthEnergyPeriod, label: EmptyView()) {
                    ForEach(HealthKitEnergyPeriodOption.allCases, id: \.self) {
                        Text($0.menuDescription).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(healthEnergyPeriod.pickerDescription)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .foregroundColor(.secondary)
                .fixedSize(horizontal: true, vertical: true)
                .animation(.none, value: healthEnergyPeriod)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
        
        return HStack {
            Text("Use")
            Spacer()
            periodPicker
            if healthEnergyPeriod == .average {
                averageIntervalTextField
                averageIntervalPicker
            }
        }
    }
    
    var healthSection: some View {
        var header: some View {
            HStack {
                appleHealthSymbol
                Text("Apple Health")
            }
        }
        
        @ViewBuilder
        var footer: some View {
            VStack(alignment: .leading, spacing: 5) {
                Group {
                    switch healthEnergyPeriod {
                    case .previousDay:
                        Text("Your maintenance energy will always be the energy your resting + active energy from the previous day. This will update daily.")
                    case .average:
                        Text("Your maintenance energy will always be the daily average of your resting + active energy from the past week. This will update daily.")
                    }
                }

                Button {
                    Haptics.feedback(style: .soft)
                    showingAdaptiveCorrectionInfo = true
                } label: {
                    Label("Learn More", systemImage: "info.circle")
                        .font(.footnote)
                }
            }
        }
        
        var healthRestingEnergyField: some View {
            HStack {
                Text("Resting Energy")
                Spacer()
                if let healthRestingEnergy {
                    Text(healthRestingEnergy.formattedEnergy)
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                    Text("kcal")
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
        }
        return Section(header: header, footer: footer) {
            healthPeriodField
            healthRestingEnergyField
            healthActiveEnergyField
            .task {
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
        }
    }
}
