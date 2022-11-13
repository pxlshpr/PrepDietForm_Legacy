import SwiftUI
import SwiftHaptics
import PrepDataTypes

extension TDEEForm {
    var manualEntrySection: some View {
        
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
                Text("Maintenance")
                Spacer()
                textField
                unitPicker
            }
        }
                
        return Section {
            Toggle(isOn: formToggleBinding($manualTDEE)) {
                VStack(alignment: .leading) {
                    Text("Enter Manually")
                }
            }
            if manualTDEE {
                tdeeTextField
            }
        }
    }
}
