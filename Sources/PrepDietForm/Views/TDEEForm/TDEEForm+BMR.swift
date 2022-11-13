import SwiftUI
import SwiftHaptics
import PrepDataTypes

extension TDEEForm {
    var bmrSection: some View {
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
        
        var picker: some View {
            Menu {
                Picker(selection: $bmrEquation, label: EmptyView()) {
                    ForEach(BMREquation.allCases, id: \.self) {
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
                .foregroundColor(.accentColor)
                .animation(.none, value: bmrEquation)
                .fixedSize(horizontal: true, vertical: true)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
        
        var bmrTextField: some View {
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
                    .foregroundColor(.accentColor)
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
                TextField("BMR in", text: bmrBinding)
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
        
        var bmrEquationPicker: some View {
            HStack {
                Text("Equation")
                Spacer()
                picker
            }
        }
        
        var manualToggle: some View {
            Toggle(isOn: formToggleBinding($manualBMR)) {
                VStack(alignment: .leading) {
                    Text("Enter Manually")
                }
            }
        }
        
        return Section(header: header) {
            if manualBMR {
                bmrTextField
            } else {
                bmrEquationPicker
            }
            //            manualToggle
        }
    }
}
