import SwiftUI
import SwiftUISugar

public struct MacroWeightForm: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TDEEForm.ViewModel
    
    let didTapSave: (BodyProfile) -> ()
    let didTapClose: () -> ()

    let existingProfile: BodyProfile?
    
    init(
        existingProfile: BodyProfile?,
        didTapSave: @escaping ((BodyProfile) -> ()),
        didTapClose: @escaping (() -> ())
    ) {
        self.existingProfile = existingProfile
        self.didTapSave = didTapSave
        self.didTapClose = didTapClose
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                form
                buttonsLayer
            }
            .toolbar { leadingContent }
        }
        .interactiveDismissDisabled(canBeSaved)
    }
    
    var form: some View {
        FormStyledScrollView {
            WeightSection(includeHeader: false)
                .environmentObject(viewModel)
                .navigationTitle("Weight")
        }
        .safeAreaInset(edge: .bottom) { safeAreaInset }
    }

    var leadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button {
                didTapClose()
                dismiss()
            } label: {
                closeButtonLabel
            }
        }
    }
    
    @ViewBuilder
    var safeAreaInset: some View {
        if canBeSaved {
            //TODO: Programmatically get this inset (67516AA6)
            Spacer()
                .frame(height: 100)
        }
    }

    @ViewBuilder
    var buttonsLayer: some View {
        if canBeSaved {
            VStack {
                Spacer()
                saveButtons
            }
            .edgesIgnoringSafeArea(.bottom)
            .transition(.move(edge: .bottom))
        }
    }

    var saveButtons: some View {
        var saveButton: some View {
            FormPrimaryButton(title: "Save") {
                didTapSave(viewModel.bodyProfile)
                dismiss()
            }
        }
        
        return VStack(spacing: 0) {
            Divider()
            VStack {
                saveButton
                    .padding(.vertical)
            }
            /// ** REMOVE THIS HARDCODED VALUE for the safe area bottom inset **
            .padding(.bottom, 30)
        }
        .background(.thinMaterial)
    }
}

extension MacroWeightForm {
    var canBeSaved:Bool {
        /// If we have an existing profile—return false if the parameters are exactly the same
        if let existingProfile {
            guard existingProfile.parameters != viewModel.bodyProfile.parameters else {
                return false
            }
        }
        /// In either case, return true only if there is a valid lean body mass value
        return viewModel.bodyProfile.hasLBM
    }
}

extension BodyProfile {
    var hasWeight: Bool {
        parameters.hasWeight
    }
}

extension BodyProfile.Parameters {
    var hasWeight: Bool {
        weight != nil && weightSource != nil
    }
}
