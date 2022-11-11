import SwiftUI

struct DoubleTextField: View {
    
    @Binding var double: Double?
    var placeholder: String = "Required"
    
    @FocusState var isFocused: Bool    
    @State var internalString: String
    
    init(double: Binding<Double?>, placeholder: String) {
        _double = double
        _internalString = State(initialValue: double.wrappedValue?.cleanAmount ?? "")
        self.placeholder = placeholder
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
                self.double = double
                withAnimation {
                    self.internalString = newValue
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
    }
    
    var textFieldFont: Font {
        internalString.isEmpty ? .body : .largeTitle
    }
    
}
