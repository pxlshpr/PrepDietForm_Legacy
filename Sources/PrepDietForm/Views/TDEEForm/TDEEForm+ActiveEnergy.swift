import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes

import Foundation

extension TDEEForm {
    var activeEnergyHealthAppPeriodField: some View {
        
        return NavigationLink {
            
        } label: {
            HStack {
                Text("Use")
                Spacer()
                Text("Average of past 2 weeks")
                    .foregroundColor(.secondary)
//                VStack(alignment: .trailing) {
//                    Text("Average Daily")
//                        .foregroundColor(.secondary)
//                    Text("of past 2 weeks")
//                        .font(.footnote)
//                        .foregroundColor(Color(.tertiaryLabel))
//                }
            }
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
                Text("Active Energy")
                    .foregroundColor(Color(.secondaryLabel))
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

        var activityLevelField: some View {
            var picker: some View {
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
                    .foregroundColor(.secondary)
                    .animation(.none, value: activityLevel)
                    .fixedSize(horizontal: true, vertical: true)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
            }
            
            return HStack {
                        Text("Activity Level")
                        Spacer()
                        picker
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
                    .foregroundColor(.secondary)
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
                activeEnergyHealthAppPeriodField
                calculatedActiveEnergyField
            case .activityLevel:
                activityLevelField
                calculatedActiveEnergyField
            case .userEntered:
                textField
            }
        }
    }
}

func formToggleBinding(_ binding: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { binding.wrappedValue },
        set: { newValue in
            Haptics.feedback(style: .soft)
            withAnimation(.interactiveSpring()) {
                binding.wrappedValue = newValue
            }
        }
    )
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

