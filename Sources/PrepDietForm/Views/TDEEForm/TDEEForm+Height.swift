import SwiftUI
import PrepDataTypes
import SwiftHaptics

extension TDEEForm {
    
    var heightField: some View {
        var unitPicker: some View {
            Menu {
                Picker(selection: $heightUnit, label: EmptyView()) {
                    ForEach(HeightUnit.allCases, id: \.self) {
                        Text($0.description).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(heightUnit.shortDescription)
                    if !viewModel.restingEnergyUsesHealthMeasurements {
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                }
                .foregroundColor(.accentColor)
                .fixedSize(horizontal: true, vertical: true)
                .animation(.none, value: heightUnit)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
            .disabled(viewModel.restingEnergyUsesHealthMeasurements)
        }
        
        let heightBinding = Binding<String>(
            get: {
                heightString
            },
            set: { newValue in
                guard !newValue.isEmpty else {
                    heightDouble = nil
                    heightString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.heightDouble = double
                withAnimation {
                    self.heightString = newValue
                }
            }
        )
        
        let heightSecondaryBinding = Binding<String>(
            get: {
                heightSecondaryString
            },
            set: { newValue in
                guard !newValue.isEmpty else {
                    heightSecondaryDouble = nil
                    heightSecondaryString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.heightSecondaryDouble = double
                withAnimation {
                    self.heightSecondaryString = newValue
                }
            }
        )
        
        var textField: some View {
            TextField("height in", text: heightBinding)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .disabled(viewModel.restingEnergyUsesHealthMeasurements)
        }

        func secondaryTextField(_ placeholder: String) -> some View {
            TextField(placeholder, text: heightSecondaryBinding)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .disabled(viewModel.restingEnergyUsesHealthMeasurements)
                .fixedSize(horizontal: true, vertical: false)
        }
        
        func secondaryUnit(_ string: String) -> some View {
            HStack(spacing: 5) {
                Text(string)
            }
            .foregroundColor(.secondary)
        }

        @ViewBuilder
        var date: some View {
            if let heightDate {
                Text("as of \(heightDate.tdeeFormat)")
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.caption)
                    .layoutPriority(1)
            }
        }

        return HStack {
            Text("Height")
            date
            Spacer()
            textField
            unitPicker
            if heightUnit == .ft {
                secondaryTextField("in")
                secondaryUnit("in")
            }
            if heightUnit == .m {
                secondaryTextField("cm")
                secondaryUnit("cm")
            }
        }
    }
}

extension Date {
    var tdeeFormat: String {
        let dayString: String
        var timeString = shortTime
        if Calendar.current.isDateInToday(self) { dayString = "Today" }
        else if Calendar.current.isDateInYesterday(self) { dayString = "Yesterday" }
        else if Calendar.current.isDateInTomorrow(self) { dayString = "Tomorrow" }
        else {
            let formatter = DateFormatter()
            let sameYear = year == Date().year
            formatter.dateFormat = sameYear ? "d MMM" : "d MMM yy"
            dayString = formatter.string(from: self)
            timeString = ""
        }
        if timeString.isEmpty {
            return dayString
        } else {
            return dayString + ", " + timeString
        }
    }
}
