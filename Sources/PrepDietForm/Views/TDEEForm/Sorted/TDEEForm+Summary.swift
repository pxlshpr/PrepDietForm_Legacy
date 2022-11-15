import SwiftUI

extension TDEEForm {
    
    var summarySection: some View {
        Button {
            transitionToEditState()
        } label: {
            HStack {
                VStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .matchedGeometryEffect(id: "maintenance-header-icon", in: namespace)
                        .foregroundColor(Color(.tertiaryLabel))
                        .imageScale(.medium)
                    Text("3,204")
                        .foregroundColor(.primary)
                        .matchedGeometryEffect(id: "maintenance", in: namespace)
                        .font(.system(.title3, design: .default, weight: .bold))
                        .monospacedDigit()
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color(.secondarySystemGroupedBackground))
                                .matchedGeometryEffect(id: "maintenance-bg", in: namespace)
                        )
                }
                VStack(spacing: 10) {
                    Image(systemName: "figure.wave")
                        .foregroundColor(Color(.tertiaryLabel))
                        .imageScale(.medium)
                        .opacity(0)
                    Text("=")
                        .matchedGeometryEffect(id: "equals", in: namespace)
                        .font(.title)
                        .foregroundColor(Color(.quaternaryLabel))
                }
                VStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "figure.wave")
                            .matchedGeometryEffect(id: "resting-header-icon", in: namespace)
                            .foregroundColor(Color(.tertiaryLabel))
                            .imageScale(.medium)
                        appleHealthSymbol
                            .imageScale(.small)
                            .matchedGeometryEffect(id: "resting-health-icon", in: namespace)
                    }
                    Text("2,024")
                        .matchedGeometryEffect(id: "resting", in: namespace)
                        .fixedSize(horizontal: true, vertical: false)
                        .font(.system(.title3, design: .default, weight: .regular))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(Color(.secondarySystemGroupedBackground))
                                    .matchedGeometryEffect(id: "resting-bg", in: namespace)
                            }
                        )
                }
                VStack(spacing: 10) {
                    Image(systemName: "figure.wave")
                        .foregroundColor(Color(.tertiaryLabel))
                        .imageScale(.medium)
                        .opacity(0)
                    Text("+")
                        .matchedGeometryEffect(id: "plus", in: namespace)
                        .font(.title)
                        .foregroundColor(Color(.quaternaryLabel))
                }
                VStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "figure.walk.motion")
                            .matchedGeometryEffect(id: "active-header-icon", in: namespace)
                            .foregroundColor(Color(.tertiaryLabel))
                            .imageScale(.medium)
                        appleHealthSymbol
                            .matchedGeometryEffect(id: "active-health-icon", in: namespace)
                            .imageScale(.small)
                    }
                    Text("1,428")
                        .matchedGeometryEffect(id: "active", in: namespace)
                        .font(.system(.title3, design: .default, weight: .regular))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color(.secondarySystemGroupedBackground))
                                .matchedGeometryEffect(id: "active-bg", in: namespace)
                        )
                }
            }
            .padding(.horizontal, 17)
        }
    }
}
