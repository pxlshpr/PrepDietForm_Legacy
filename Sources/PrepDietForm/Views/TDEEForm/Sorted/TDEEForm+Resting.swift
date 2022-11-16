import SwiftUI
import SwiftHaptics
import PrepDataTypes
import ActivityIndicatorView

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
//                        .font(.title3)
                        .foregroundColor(.secondary)
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
            var menu: some View {
                let binding = Binding<RestingEnergySourceOption>(
                    get: { viewModel.restingEnergySource ?? .userEntered },
                    set: { newValue in
                        Haptics.feedback(style: .soft)
                        withAnimation {
                            viewModel.restingEnergySource = newValue
                        }
                    }
                )

                return Menu {
                    Picker(selection: binding, label: EmptyView()) {
                        ForEach(RestingEnergySourceOption.allCases, id: \.self) {
                            Label($0.menuDescription, systemImage: $0.systemImage).tag($0)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        HStack {
                            if viewModel.restingEnergySource == .healthApp {
                                appleHealthSymbol
                            } else {
                                if let systemImage = viewModel.restingEnergySource?.systemImage {
                                    Image(systemName: systemImage)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Text(viewModel.restingEnergySource?.pickerDescription ?? "")
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundColor(.secondary)
                    .animation(.none, value: viewModel.restingEnergySource)
                    .fixedSize(horizontal: true, vertical: false)
                }
                .contentShape(Rectangle())
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .light)
                })
            }
            
            return HStack {
                menu
                Spacer()
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
            if let source = viewModel.restingEnergySource {
                switch source {
                case .healthApp:
                    healthContent
                        .onAppear {
                            print("Appeared")
                        }
                default:
                    healthContent
                }
            } else {
                emptyContent
            }
        }
        
        func tappedSyncWithHealth() {
            Task(priority: .high) {
                do {
                    try await HealthKitManager.shared.requestPermission(for: .basalEnergyBurned)
                    
                    withAnimation {
                        viewModel.restingEnergySource = .healthApp
                    }
                    
                    viewModel.fetchRestingEnergyFromHealth()

                } catch {
                    
                }
            }
        }

        var emptyContent: some View {
            VStack(spacing: 10) {
                emptyButton("Sync with Health app", showHealthAppIcon: true, action: tappedSyncWithHealth)
                emptyButton("Calculate using Formula", systemImage: "function")
                emptyButton("Let me type it in", systemImage: "keyboard")
            }
        }
        
        var healthContent: some View {
            VStack {
                topSection
                Group {
                    if viewModel.restingEnergyFetchStatus == .notAuthorized {
                        permissionRequiredContent
                    } else {
                        healthPeriodContent
                    }
                }
                .padding()
                .padding(.horizontal)
                energyRow
            }
        }
        
        @ViewBuilder
        var energyRow: some View {
            if viewModel.restingEnergyFetchStatus != .notAuthorized {
                HStack {
                    Spacer()
                    if viewModel.hasDynamicRestingEnergy {
                        Text("currently")
                            .font(.subheadline)
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    if viewModel.restingEnergyFetchStatus == .fetching {
                        ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                            .frame(width: 25, height: 25)
                            .foregroundColor(.secondary)
                    } else {
                        Text(viewModel.restingEnergyFormatted)
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .matchedGeometryEffect(id: "resting", in: namespace)
                            .if(!viewModel.hasRestingEnergy) { view in
                                view
                                    .redacted(reason: .placeholder)
                            }
                    }
                    Text(viewModel.userEnergyUnit.shortDescription)
                        .foregroundColor(.secondary)
                }
                .padding(.trailing)
            }
        }
        
        var healthPeriodContent: some View {
            var periodTypeMenu: some View {
                let binding = Binding<HealthPeriodOption>(
                    get: { viewModel.restingEnergyPeriod },
                    set: { newPeriod in
                        Haptics.feedback(style: .soft)
                        withAnimation {
                            viewModel.restingEnergyPeriod = newPeriod
                        }
                    }
                )
                
                return Menu {
                    Picker(selection: binding, label: EmptyView()) {
                        ForEach(HealthPeriodOption.allCases, id: \.self) {
                            Text($0.pickerDescription).tag($0)
                        }
                    }
                } label: {
                    PickerLabel(viewModel.restingEnergyPeriod.menuDescription)
                        .animation(.none, value: viewModel.restingEnergyPeriod)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            
            var periodValueMenu: some View {
                let binding = Binding<Int>(
                    get: { viewModel.restingEnergyIntervalValue },
                    set: { newValue in
                        guard newValue >= viewModel.restingEnergyInterval.minValue,
                              newValue <= viewModel.restingEnergyInterval.maxValue else {
                            return
                        }
                        Haptics.feedback(style: .soft)
                        withAnimation {
                            viewModel.restingEnergyIntervalValue = newValue
                        }
                        viewModel.fetchRestingEnergyFromHealth()
                    }
                )
                return Menu {
                    Picker(selection: binding, label: EmptyView()) {
                        ForEach(Array(viewModel.restingEnergyInterval.minValue...viewModel.restingEnergyInterval.maxValue), id: \.self) { quantity in
                            Text("\(quantity)").tag(quantity)
                        }
                    }
                } label: {
                    PickerLabel("\(viewModel.restingEnergyIntervalValue)")
                        .animation(.none, value: viewModel.restingEnergyIntervalValue)
                        .animation(.none, value: viewModel.restingEnergyInterval)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            
            var periodIntervalMenu: some View {
                let binding = Binding<HealthAppInterval>(
                    get: { viewModel.restingEnergyInterval },
                    set: { newInterval in
                        Haptics.feedback(style: .soft)
                        withAnimation {
                            viewModel.restingEnergyInterval = newInterval
                        }
                        viewModel.fetchRestingEnergyFromHealth()
                    }
                )
                return Menu {
                    Picker(selection: binding, label: EmptyView()) {
                        ForEach(HealthAppInterval.allCases, id: \.self) { interval in
                            Text("\(interval.description)\(viewModel.restingEnergyIntervalValue > 1 ? "s" : "")").tag(interval)
                        }
                    }
                } label: {
                    PickerLabel("\(viewModel.restingEnergyInterval.description)\(viewModel.restingEnergyIntervalValue > 1 ? "s" : "")")
                        .animation(.none, value: viewModel.restingEnergyInterval)
                        .animation(.none, value: viewModel.restingEnergyIntervalValue)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            
            var intervalRow: some View {
                HStack {
                    Spacer()
                    HStack(spacing: 5) {
                        Text("previous")
                            .foregroundColor(Color(.secondaryLabel))
                        periodValueMenu
                        periodIntervalMenu
                    }
                    Spacer()
                }
            }
            
            return VStack(spacing: 5) {
                HStack {
                    Spacer()
                    HStack {
                        Text("Using")
                            .foregroundColor(.secondary)
                        periodTypeMenu
                    }
                    Spacer()
                }
                if viewModel.restingEnergyPeriod == .average {
                    intervalRow
                }
            }
        }
        
        var permissionRequiredContent: some View  {
            VStack {
                VStack(alignment: .center, spacing: 5) {
                    Text("Health app integration requires permissions to be granted in:")
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.secondary)
                    Text("Settings → Privacy & Security → Health → Prep")
                        .font(.footnote)
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .multilineTextAlignment(.center)
                Button {
                    UIApplication.shared.open(URL(string: "App-prefs:Privacy&path=HEALTH")!)
//                            UIApplication.shared.open(URL(string: "\(UIApplication.openSettingsURLString)&path=HEALTH")!)
                } label: {
                    HStack {
                        Image(systemName: "gear")
                        Text("Go to Settings")
                            .fixedSize(horizontal: true, vertical: false)
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
        
        var formulaContent: some View {
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

extension TDEEForm {
    class ViewModel: ObservableObject {
        let userEnergyUnit: EnergyUnit
        
        @Published var hasAppeared = false
        @Published var activeEnergySource: ActiveEnergySourceOption? = nil
        
        @Published var isEditing = false
        @Published var presentationDetent: PresentationDetent = .height(270)
        @Published var restingEnergySource: RestingEnergySourceOption? = nil
//        @Published var isEditing = true
//        @Published var presentationDetent: PresentationDetent = .large
//        @Published var restingEnergySource: RestingEnergySourceOption? = .healthApp

        @Published var restingEnergy: Double? = nil
        
        @Published var restingEnergyPeriod: HealthPeriodOption = .average
        @Published var restingEnergyIntervalValue: Int = 1
        @Published var restingEnergyInterval: HealthAppInterval = .week
        
        @Published var restingEnergyFetchStatus: HealthKitFetchStatus = .notFetched
        @Published var restingEnergyUsesHealthMeasurements: Bool = false

        init(userEnergyUnit: EnergyUnit) {
            self.userEnergyUnit = userEnergyUnit
        }
    }
}

enum HealthKitFetchStatus {
    case notFetched
    case fetching
    case fetched
    case notAuthorized
}

struct TDEEForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    TDEEFormPreview()
                }
        }
    }
}
