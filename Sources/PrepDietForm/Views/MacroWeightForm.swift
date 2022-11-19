import SwiftUI
import SwiftUISugar

public struct MacroWeightForm: View {
    
    @EnvironmentObject var viewModel: TDEEForm.ViewModel
    
    public var body: some View {
        NavigationView {
            FormStyledScrollView {
                WeightSection()
                    .navigationTitle("Weight")
            }
        }
    }
}
