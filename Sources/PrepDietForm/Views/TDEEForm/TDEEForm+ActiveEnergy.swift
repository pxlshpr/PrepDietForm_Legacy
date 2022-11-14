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
            Text(syncHealthKitActiveEnergy ? "Your active energy will be what you burned the day before. This will update your maintenance energy daily." : "A scale factor of \(activityLevel.scaleFactor.cleanAmount)× will be applied to your resting energy.")
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
            Toggle(isOn: formToggleBinding($syncHealthKitActiveEnergy)) {
                HStack {
                    appleHealthSymbol
                    Text("Get from Apple Health")
                }
            }
        }
        
        
        return Section(header: header, footer: footer) {
            healthToggle
            if syncHealthKitActiveEnergy {
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

