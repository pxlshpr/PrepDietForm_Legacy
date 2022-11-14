import SwiftUI
import SwiftHaptics
import PrepDataTypes

extension TDEEForm {
    var sourceSection: some View {
        
        var sourcePicker: some View {
            let tdeeSourceBinding = Binding<TDEESourceOption>(
                get: { tdeeSource },
                set: { newValue in
                    Haptics.feedback(style: .soft)
                    withAnimation {
                        tdeeSource = newValue
                    }
                }
            )
            
            return Menu {
                Picker(selection: tdeeSourceBinding, label: EmptyView()) {
                    ForEach(TDEESourceOption.allCases, id: \.self) {
                        Label($0.menuDescription, systemImage: $0.systemImage).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(tdeeSource.pickerDescription)
                        .frame(maxWidth: .infinity, alignment: .trailing)
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
        
        var restingEnergyField: some View {
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
                Text("Resting Energy")
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
                restingEnergyField
            default:
                EmptyView()
            }
        }
    }
}
