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
        
        @ViewBuilder
        var footer: some View {
            if syncHealthKitActiveEnergy {
                Text("Your daily active energy from HealthKit will be added to your maintenance calories whenever available.")
            }
        }

        var activityLevelField: some View {
            var picker: some View {
                Menu {
                    Picker(selection: $activityLevel, label: EmptyView()) {
                        ForEach(BMRActivityLevel.allCases, id: \.self) {
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
        
        return Section(header: header, footer: footer) {
            Toggle(isOn: formToggleBinding($syncHealthKitActiveEnergy)) {
                HStack {
                    Image(systemName: "heart.fill")
                        .renderingMode(.original)
                    Text("Sync with HealthKit")
                }
            }
            if !syncHealthKitActiveEnergy {
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
