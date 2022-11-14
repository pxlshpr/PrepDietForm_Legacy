import SwiftUI
import SwiftHaptics
import PrepDataTypes


enum HealthKitEnergyPeriodOption: CaseIterable {
    case previousDay
    case average
    
    var menuDescription: String {
        switch self {
        case .previousDay:
            return "Previous Day"
        case .average:
            return "Daily Average"
        }
    }
    var pickerDescription: String {
        switch self {
        case .previousDay:
            return "Previous Day"
        case .average:
            return "Average of"
        }
    }
}
extension TDEEForm {

    var restingEnergyFormulaField: some View {
        var picker: some View {
            Menu {
                Picker(selection: $bmrEquation, label: EmptyView()) {
                    ForEach(TDEEFormula.latest, id: \.self) { formula in
                        Text(formula.description).tag(formula)
                    }
                    Divider()
                    ForEach(TDEEFormula.legacy, id: \.self) { formula in
                        Text(formula.description).tag(formula)
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
        
        return NavigationLink {
            Form {
                Section {
                    HStack {
                        Text("Formula")
                        Spacer()
                        picker
                    }
                }
                bodyMeasurementsSection
            }
            .navigationTitle("Resting Energy")
        } label: {
            HStack {
                Text("Formula")
                Spacer()
                Text(bmrEquation.description)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    var restingEnergySection: some View {
        var header: some View {
            Text("Resting Energy")
        }
        
        var picker: some View {
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
                .foregroundColor(.accentColor)
                .animation(.none, value: bmrEquation)
                .fixedSize(horizontal: true, vertical: true)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
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
            if tdeeSource == .userEntered {
                textField
            } else {
                restingEnergyFormulaField
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

