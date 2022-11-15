import SwiftUI
import SwiftHaptics
import PrepDataTypes
import SwiftUISugar

extension TDEEForm {

    var legacyForm: some View {
        Form {
//                restingEnergySection
            activeEnergySection
//                adaptiveCorrectionSection
        }
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
    
    var formHealth: some View {
        FormStyledScrollView {
            restingHealthSection
            activeHealthSection
        }
    }

    var activeEnergySection: some View {
        var header: some View {
            Text("Active Energy")
        }
        
        var footer: some View {
            var string: String {
                if activeEnergySource == .healthApp {
                    return "Your active energy will be what you burned the day before. This will update daily."
                } else if activeEnergySource == .activityLevel {
                    if activityLevel == .notSet {
                        return ""
//                        return "Your maintenance energy equals your resting energy as no activity level is set."
                    } else {
                        return "A scale factor of \(activityLevel.scaleFactor.cleanAmount)× is being applied to your resting energy to calculate this."
                    }
                } else {
                    return ""
                }
            }
            return Group {
                if !string.isEmpty {
                    Text(string)
                }
            }
        }

        
        var calculatedActiveEnergyField: some View {
            HStack {
                if activeEnergySource == .activityLevel {
                    activityLevelPicker
                } else {
                    activeEnergyHealthAppPeriodLink
//                        .background(Color.blue)
                }
                Spacer()
                Group {
                    if isSwiftUIPreview {
                        Text("1,228")
                    } else {
                        if let healthActiveEnergy {
                            Text(healthActiveEnergy.formattedEnergy)
                        }
                    }
                }
                .monospacedDigit()
                .foregroundColor(.secondary)
                Text("kcal")
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }

        var activityLevelPicker: some View {
            Menu {
                Picker(selection: $activityLevel, label: EmptyView()) {
                    ForEach(ActivityLevel.allCases, id: \.self) {
                        Text($0.description).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(activityLevel.description)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.accentColor)
                .animation(.none, value: activityLevel)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
        
        var activityLevelField: some View {
            HStack {
                Text("Activity Level")
                Spacer()
                activityLevelPicker
            }
        }
        
        var sourceField: some View {
            var picker: some View {
                let tdeeSourceBinding = Binding<ActiveEnergySourceOption>(
                    get: { activeEnergySource },
                    set: { newValue in
                        Haptics.feedback(style: .soft)
                        withAnimation {
                            activeEnergySource = newValue
                        }
                    }
                )
                
                return Menu {
                    Picker(selection: tdeeSourceBinding, label: EmptyView()) {
                        ForEach(ActiveEnergySourceOption.allCases, id: \.self) {
                            Label($0.menuDescription, systemImage: $0.systemImage).tag($0)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        HStack {
                            if activeEnergySource == .healthApp {
                                appleHealthSymbol
                            }
                            Text(activeEnergySource.pickerDescription)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundColor(.accentColor)
                    .animation(.none, value: activeEnergySource)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
            }
            return HStack {
                Text("Source")
                Spacer()
                picker
            }
        }

        var textField: some View {
            var unitPicker: some View {
                Menu {
                    Picker(selection: $bmrUnit, label: EmptyView()) {
                        ForEach(EnergyUnit.allCases, id: \.self) {
                            Text($0.shortDescription).tag($0)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(bmrUnit.shortDescription)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: true, vertical: true)
                    .animation(.none, value: bmrUnit)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
            }
            
            let bmrBinding = Binding<String>(
                get: {
                    bmrString
                },
                set: { newValue in
                    guard !newValue.isEmpty else {
                        bmrDouble = nil
                        bmrString = newValue
                        return
                    }
                    guard let double = Double(newValue) else {
                        return
                    }
                    bmrDouble = double
                    withAnimation {
                        bmrString = newValue
                    }
                }
            )
            
            var textField: some View {
                TextField("Resting Energy in", text: bmrBinding)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            
            return HStack {
                Text("Resting Energy")
                Spacer()
                textField
                unitPicker
            }
        }
        
        
        return Section(header: header, footer: footer) {
            sourceField
            switch activeEnergySource {
            case .healthApp:
//                activeEnergyHealthAppPeriodLink
                calculatedActiveEnergyField
            case .activityLevel:
//                activityLevelField
                calculatedActiveEnergyField
            case .userEntered:
                textField
            }
        }
    }

}
