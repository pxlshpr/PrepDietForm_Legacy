import SwiftUI

extension TDEEForm {
    
    var promptSection: some View {
        VStack {
            Text("This is an estimate of how many calories you would need to consume to *maintain* your current weight.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.tertiaryLabel))
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
    
}
