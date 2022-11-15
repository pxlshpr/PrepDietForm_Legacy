import SwiftUI

struct PickerLabel: View {
    
    let string: String
    let prefix: String?
    let systemImage: String
    let imageColor: Color
    let imageScale: Image.Scale
    let infiniteMaxHeight: Bool
    
    init(
        _ string: String,
        prefix: String? = nil,
        systemImage: String = "chevron.up.chevron.down",
        imageColor: Color = Color(.tertiaryLabel),
        imageScale: Image.Scale = .small,
        infiniteMaxHeight: Bool = true
    ) {
        self.string = string
        self.prefix = prefix
        self.systemImage = systemImage
        self.imageColor = imageColor
        self.imageScale = imageScale
        self.infiniteMaxHeight = infiniteMaxHeight
    }
    
    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .foregroundColor(Color(.secondarySystemFill))
            HStack(spacing: 5) {
                if let prefix {
                    Text(prefix)
                        .foregroundColor(.secondary)
                }
                Text(string)
                    .foregroundColor(.primary)
                Image(systemName: systemImage)
                    .foregroundColor(imageColor)
                    .imageScale(imageScale)
            }
            .frame(height: 25)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
        }
        .fixedSize(horizontal: true, vertical: true)
        .if(infiniteMaxHeight) {
            $0.frame(maxHeight: .infinity)
        }
    }
}
