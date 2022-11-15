import SwiftUI
import SwiftHaptics
import PrepDataTypes

extension TDEEForm {
    
    func emptyButton(_ string: String, systemImage: String? = nil, showHealthAppIcon: Bool = false, action: (() -> ())? = nil) -> some View {
        Button {
            action?()
        } label: {
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(Color(.secondarySystemFill))
                HStack(spacing: 5) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .foregroundColor(.secondary)
                    } else if showHealthAppIcon {
                        appleHealthSymbol
                    }
                    Text(string)
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                .frame(height: 35)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
            }
            .fixedSize(horizontal: true, vertical: true)
        }
    }
    
    var restingEnergySection: some View {
        let useHealthAppDataBinding = Binding<Bool>(
            get: { useHealthAppData },
            set: { newValue in
                withAnimation {
                    useHealthAppData = newValue
                }
            }
        )
        var useHealthAppToggle: some View {
            Toggle(isOn: useHealthAppDataBinding) {
                HStack {
                    appleHealthSymbol
                        .matchedGeometryEffect(id: "resting-health-icon", in: namespace)
                    Text("Sync\(useHealthAppData ? "ed" : "") with Health App")
                }
            }
            .toggleStyle(.button)
        }
        
        var topSection: some View {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "function")
                        .foregroundColor(.secondary)
                    Text("Calculated")
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(Color(.tertiaryLabel))
                        .imageScale(.small)
                }
                Spacer()
                //                useHealthAppToggle
            }
            .padding(.horizontal, 17)
        }
        
        var formulaRow: some View {
            HStack {
                HStack {
                    Text("Using")
                        .foregroundColor(.secondary)
                    PickerLabel("Katch-McArdle")
                    Text("equation")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
        
        var flowView: some View {
            func label(_ prefix: String, _ string: String) -> some View {
                var backgroundColor: Color {
                    return colorScheme == .light ? Color(hex: "e8e9ea") : Color(hex: "434447")
                }
                return PickerLabel(
                    string,
                    prefix: prefix,
                    systemImage: useHealthAppData ? nil : "chevron.right",
                    //                    imageColor: <#T##Color#>,
                    backgroundColor:  useHealthAppData ? Color(.systemGroupedBackground) : backgroundColor,
                    foregroundColor: useHealthAppData ? Color(.secondaryLabel) : Color.primary,
                    prefixColor: useHealthAppData ? Color(.tertiaryLabel) : Color.secondary,
                    //                    imageScale: <#T##Image.Scale#>,
                    infiniteMaxHeight: false
                )
            }
            
            return FlowView(alignment: .center, spacing: 10, padding: 17) {
                ZStack {
                    Capsule(style: .continuous)
                        .foregroundColor(Color(.clear))
                    HStack(spacing: 5) {
                        Text("with")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .frame(height: 25)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                }
                .fixedSize(horizontal: true, vertical: true)
                Menu {
                    Picker(selection: .constant(true), label: EmptyView()) {
                        Text("Male").tag(true)
                        Text("Female").tag(false)
                    }
                } label: {
                    label("sex", "male")
                }
                Button {
                    path.append(.fatPercentageForm)
                } label: {
                    label("fat", "29 %")
                }
                Button {
                    path.append(.weightForm)
                } label: {
                    label("weight", "93.55 kg")
                }
                Button {
                    path.append(.heightForm)
                } label: {
                    label("height", "177 cm")
                }
            }
            .padding(.bottom, 5)
        }
        
        @ViewBuilder
        var content: some View {
            if viewModel.restingEnergySource == nil {
                emptyContent
            } else {
                filledContent
            }
        }
        
        func tappedSyncWithHealth() {
            Task {
                await HealthKitManager.shared.requestPermission(for: .basalEnergyBurned)
            }
        }

        var emptyContent: some View {
            VStack(spacing: 10) {
                emptyButton("Sync with Health App", showHealthAppIcon: true, action: tappedSyncWithHealth)
                emptyButton("Calculate using Formula", systemImage: "function")
                emptyButton("Let me type it in", systemImage: "keyboard")
            }
        }
        
        var filledContent: some View {
            VStack {
                topSection
                formulaRow
                Divider()
                    .frame(width: 300)
                    .padding(.vertical, 5)
                flowView
                useHealthAppToggle
                    .padding(.bottom)
                HStack {
                    Spacer()
                    Text("2,024")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .matchedGeometryEffect(id: "resting", in: namespace)
                    Text("kcal")
                        .foregroundColor(.secondary)
                }
                .padding(.trailing)
            }
        }
        
        return VStack(spacing: 7) {
                restingHeader
                    .textCase(.uppercase)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                content
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 0)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.secondarySystemGroupedBackground))
                        .matchedGeometryEffect(id: "resting-bg", in: namespace)
                )
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
    }
}
