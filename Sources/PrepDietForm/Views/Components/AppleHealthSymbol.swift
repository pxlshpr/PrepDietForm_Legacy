import SwiftUI

let AppleHealthBottomColorHex = "fc2e1d"
let AppleHealthTopColorHex = "fe5fab"

var appleHealthSymbol: some View {
    Image(systemName: "heart.fill")
        .symbolRenderingMode(.palette)
        .foregroundStyle(
            .linearGradient(
                colors: [
                    Color(hex: AppleHealthTopColorHex),
                    Color(hex: AppleHealthBottomColorHex)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
}
