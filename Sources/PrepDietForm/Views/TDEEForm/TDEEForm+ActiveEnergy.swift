import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes

import Foundation

extension TDEEForm {
    var activeEnergySection: some View {
        var header: some View {
            HStack {
                Text("Active Energy")
            }
        }
        
        var footer: some View {
            var string: String {
                if useHealthActiveEnergy {
                    return "Your active energy will be what you burned the day before. This will update your maintenance energy daily."
                } else if activityLevel == .notSet {
                    return "Your maintenance energy equals your resting energy as no activity level is set."
                } else {
                    return "A scale factor of \(activityLevel.scaleFactor.cleanAmount)× will be applied to your resting energy."
                }
            }
            return Text(string)
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
                    .foregroundColor(.accentColor)
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
        
        var healthToggle: some View {
            Toggle(isOn: formToggleBinding($useHealthActiveEnergy)) {
                HStack {
                    appleHealthSymbol
                    Text("Get from Apple Health")
                }
            }
        }
        
        
        return Section(header: header, footer: footer) {
            healthToggle
            if useHealthActiveEnergy {
                healthPeriodField
                healthActiveEnergyField
            } else {
                activityLevelField
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
