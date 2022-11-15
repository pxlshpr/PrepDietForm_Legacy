import SwiftUI

extension TDEEForm {
    
    var promptSection: some View {
        VStack {
            Text("This is an estimate of how many calories you would need to consume to *maintain* your current weight.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.tertiaryLabel))
            if viewModel.notSetup {
                Button {
                    transitionToEditState()
                } label: {
                    HStack {
                        Image(systemName: "flame.fill")
                            .matchedGeometryEffect(id: "maintenance-header-icon", in: namespace)
                        Text("Setup Maintenance Calories")
                            .fixedSize(horizontal: true, vertical: false)
                            .matchedGeometryEffect(id: "maintenance-header-title", in: namespace)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .foregroundColor(Color.accentColor)
                    )
                }
                .buttonStyle(.borderless)
                .padding(.top, 5)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundColor(Color(.quaternarySystemFill))
        )
        .cornerRadius(10)
        .padding(.bottom, 10)
        .padding(.horizontal, 17)
    }
    
    /// [ ] Find a way to align the array without having to replicate the entire contents.
    var arrowSection: some View {
        HStack {
            ZStack {
                Text("3,204")
                    .foregroundColor(.primary)
                    .font(.system(.title3, design: .default, weight: .bold))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color(.secondarySystemGroupedBackground))
                    )
                    .opacity(0)
                Image(systemName: "arrow.down")
                    .foregroundColor(Color(.quaternaryLabel))
                    .fontWeight(.light)
                    .font(.largeTitle)
            }
            Text("=")
                .font(.title)
                .foregroundColor(Color(.quaternaryLabel))
                .opacity(0)
            Text("2,204")
                .font(.system(.title3, design: .default, weight: .regular))
                .foregroundColor(.primary)
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color(.secondarySystemGroupedBackground))
                    }
                )
                .opacity(0)
            Text("+")
                .font(.title)
                .foregroundColor(Color(.quaternaryLabel))
                .opacity(0)
            Text("1,428")
                .font(.system(.title3, design: .default, weight: .regular))
                .foregroundColor(.primary)
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color(.secondarySystemGroupedBackground))
                )
                .opacity(0)
        }
        .padding(.horizontal, 17)
    }
    
    var trailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if !viewModel.notSetup {
                Button {
                    toggleEditState()
                } label: {
                    Text(viewModel.isEditing ? "Save" : "Edit")
//                    Image(systemName: isEditing ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                }
//                if valuesHaveChanged {
//                    Button {
//                        Haptics.successFeedback()
//                        dismiss()
//                    } label: {
//                        Text("Save")
//                            .bold()
//                    }
//                }
            }
        }
    }
}
