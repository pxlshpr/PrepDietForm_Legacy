import SwiftUI

struct DoubleTextField: View {
    
    @Binding var double: Double?
    var placeholder: String = "Required"
    
    @FocusState var isFocused: Bool    
    @State var internalString: String
    
    let focusOnAppear: Bool
    
    let validator: ((Double) -> (Double))?
    init(double: Binding<Double?>, placeholder: String, focusOnAppear: Bool = false, validator: ((Double) -> (Double))? = nil) {
        _double = double
        _internalString = State(initialValue: double.wrappedValue?.cleanAmount ?? "")
        self.placeholder = placeholder
        self.focusOnAppear = focusOnAppear
        self.validator = validator
    }
    
    var body: some View {
        let binding = Binding<String>(
            get: {
                internalString
            },
            set: { newValue in
                guard !newValue.isEmpty else {
                    double = nil
                    internalString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                var validatedDouble = double
                if let validator {
                    validatedDouble = validator(double)
                }
                self.double = validatedDouble
                withAnimation {
                    self.internalString = validatedDouble.cleanAmount
                }
            }
        )
        
        return TextField(placeholder, text: binding)
            .multilineTextAlignment(.leading)
            .focused($isFocused)
            .font(textFieldFont)
            .keyboardType(.decimalPad)
            .frame(minHeight: 50)
            .scrollDismissesKeyboard(.interactively)
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                if let textField = obj.object as? UITextField {
                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                }
            }
            .onTapGesture {
                isFocused = true
            }
            .onAppear {
                if focusOnAppear {
                    self.isFocused = true
                }
            }
            .onChange(of: double, perform: doubleChanged)
    }
    
    /// Detect external changes
    func doubleChanged(to newDouble: Double?) {
        withAnimation {
            self.internalString = newDouble?.cleanAmount ?? ""
        }
    }
    
    var textFieldFont: Font {
        internalString.isEmpty ? .body : .largeTitle
    }
    
}
