import SwiftUI

struct PickerLabel: View {
    
    let string: String
    let prefix: String?
    let systemImage: String?
    let imageColor: Color
    let imageScale: Image.Scale
    let infiniteMaxHeight: Bool
    
    let backgroundColor: Color
    let prefixColor: Color
    let foregroundColor: Color
    
    init(
        _ string: String,
        prefix: String? = nil,
        systemImage: String? = "chevron.up.chevron.down",
        imageColor: Color = Color(.tertiaryLabel),
        backgroundColor: Color = Color(.secondarySystemFill),
        foregroundColor: Color = Color(.label),
        prefixColor: Color = Color(.secondaryLabel),
        imageScale: Image.Scale = .small,
        infiniteMaxHeight: Bool = true
    ) {
        self.string = string
        self.prefix = prefix
        self.systemImage = systemImage
        self.imageColor = imageColor
        self.imageScale = imageScale
        self.infiniteMaxHeight = infiniteMaxHeight
        
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.prefixColor = prefixColor
    }
    
    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .foregroundColor(.white)
                .colorMultiply(backgroundColor)
            HStack(spacing: 5) {
                if let prefix {
                    Text(prefix)
                        .foregroundColor(.white)
                        .colorMultiply(prefixColor)
                }
                Text(string)
                    .foregroundColor(.white)
                    .colorMultiply(foregroundColor)
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundColor(imageColor)
                        .imageScale(imageScale)
                }
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
