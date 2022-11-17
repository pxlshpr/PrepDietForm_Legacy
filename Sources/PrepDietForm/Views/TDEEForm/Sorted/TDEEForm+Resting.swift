import SwiftUI
import SwiftHaptics
import PrepDataTypes
import ActivityIndicatorView
import SwiftUISugar

//func label(_ label: String, _ valueString: String) -> some View {

//let AppleHealthBottomColorHex = "fc2e1d"
//let AppleHealthTopColorHex = "fe5fab"

//var appleHealthSymbol: some View {
//    Image(systemName: "heart.fill")
//        .symbolRenderingMode(.palette)
//        .foregroundStyle(
//            .linearGradient(
//                colors: [
//                    Color(hex: AppleHealthTopColorHex),
//                    Color(hex: AppleHealthBottomColorHex)
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//        )
//}

struct MeasurementLabel: View {
    @Environment(\.colorScheme) var colorScheme
    
    let label: String
    let valueString: String
    let useHealthAppData: Bool
    
    var body: some View {
        PickerLabel(
            string,
            prefix: prefix,
            systemImage: useHealthAppData ? nil : "chevron.right",
            imageColor: imageColor,
            backgroundColor: backgroundColor,
            backgroundGradientTop: backgroundGradientTop,
            backgroundGradientBottom: backgroundGradientBottom,
            foregroundColor: foregroundColor,
            prefixColor: prefixColor,
            infiniteMaxHeight: false
        )
    }
    var backgroundGradientTop: Color? {
        guard useHealthAppData else {
            return nil
        }
        return Color(hex: AppleHealthTopColorHex)
    }
    var backgroundGradientBottom: Color? {
        guard useHealthAppData else {
            return nil
        }
        return Color(hex: AppleHealthBottomColorHex)
    }

    var backgroundColor: Color {
        guard !valueString.isEmpty else {
            return .accentColor
        }
        let defaultColor = colorScheme == .light ? Color(hex: "e8e9ea") : Color(hex: "434447")
        return useHealthAppData ? Color(.systemGroupedBackground) : defaultColor
    }
    
    var foregroundColor: Color {
        guard !valueString.isEmpty else {
            return .white
        }
        if useHealthAppData {
            return Color.white
//            return Color(.secondaryLabel)
        } else {
            return Color.primary
        }
    }
    var prefixColor: Color {
        if useHealthAppData {
            return Color(hex: "F3DED7")
//            return Color(.secondaryLabel)
//            return Color(.tertiaryLabel)
        } else {
            return Color.secondary
        }
    }
    
    var string: String {
        valueString.isEmpty ? label : valueString
    }
    
    var prefix: String? {
        valueString.isEmpty ? nil : label
    }
    
    var imageColor: Color {
        valueString.isEmpty ? .white : Color(.tertiaryLabel)
    }
}

struct MeasurementLabel_Previews: PreviewProvider {
    static var previews: some View {
        FormStyledScrollView {
            FormStyledSection {
                MeasurementLabel(
                    label: "weight",
                    valueString: "93.55",
                    useHealthAppData: true
                )
            }
        }
    }
}

extension TDEEForm.ViewModel {
    
    var restingEnergyFormulaUsingSyncedHealthDataBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                switch self.restingEnergyFormula {
                case .katchMcardle:
                    return self.lbmSource == .healthApp
                default:
                    /// return true if sex, weight and height are all healthApp
                    return false
                }
            },
            set: { isOn in
                switch self.restingEnergyFormula {
                case .katchMcardle:
                    /// toggle lbm between health and userEntered
                    self.changeLBMSource(to: isOn ? .healthApp : .userEntered)
                default:
                    //TODO: attempt to change the source of weight, height and sex to healthApp or all to userEntered
                    break
                }
            }
        )
    }
    
    var restingEnergyFormulaUsingSyncedHealthData: Bool {
        restingEnergyFormulaUsingSyncedHealthDataBinding.wrappedValue
    }
}
extension TDEEForm {
    
    var restingEnergySection: some View {
        var syncWithHealthAppToggle: some View {
            Toggle(isOn: viewModel.restingEnergyFormulaUsingSyncedHealthDataBinding) {
                HStack {
                    appleHealthSymbol
                        .matchedGeometryEffect(id: "resting-health-icon", in: namespace)
                    Text("Sync\(viewModel.restingEnergyFormulaUsingSyncedHealthData ? "ed" : "") with Health App")
                }
            }
            .toggleStyle(.button)
        }
        
        var sourceSection: some View {
            var sourceMenu: some View {
                Menu {
                    Picker(selection: viewModel.restingEnergySourceBinding, label: EmptyView()) {
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
                sourceMenu
                Spacer()
            }
            .padding(.horizontal, 17)
        }
        
        //MARK: - Formula Content
        
        var formulaContent: some View {
            VStack {
                formulaRow
                Divider()
                    .frame(width: 300)
                    .padding(.vertical, 5)
                flowView
                syncWithHealthAppToggle
                    .padding(.bottom)
            }
        }
        
        var formulaRow: some View {
            var formulaMenu: some View {
                Menu {
                    Picker(selection: viewModel.restingEnergyFormulaBinding, label: EmptyView()) {
                        ForEach(RestingEnergyFormula.latest, id: \.self) {
                            Text($0.description).tag($0)
                        }
                        Divider()
                        ForEach(RestingEnergyFormula.legacy, id: \.self) {
                            Text($0.description).tag($0)
                        }
                    }
                } label: {
                    PickerLabel(viewModel.restingEnergyFormula.description)
                        .animation(.none, value: viewModel.restingEnergyFormula)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            return HStack {
                HStack {
                    Text("Using")
                        .foregroundColor(.secondary)
                    formulaMenu
                }
            }
            .padding(.top, 8)
        }
        
        var flowView: some View {
            
            return FlowView(alignment: .center, spacing: 10, padding: 17) {
                ZStack {
                    Capsule(style: .continuous)
                        .foregroundColor(Color(.clear))
                    Text("with")
                        .foregroundColor(Color(.tertiaryLabel))
                    .frame(height: 25)
                    .padding(.vertical, 5)
                    .padding(.bottom, 2)
                }
                .fixedSize(horizontal: true, vertical: true)
                if viewModel.restingEnergyFormula == .katchMcardle {
                    Button {
                        viewModel.path.append(.leanBodyMassForm)
                    } label: {
                        MeasurementLabel(
                            label: "lean body mass",
                            valueString: viewModel.lbmFormattedWithUnit,
                            useHealthAppData: viewModel.restingEnergyFormulaUsingSyncedHealthData
                        )
                    }
                } else {
                    Menu {
                        Picker(selection: .constant(true), label: EmptyView()) {
                            Text("Male").tag(true)
                            Text("Female").tag(false)
                        }
                    } label: {
                        MeasurementLabel(
                            label: "sex",
                            valueString: "male",
                            useHealthAppData: viewModel.restingEnergyFormulaUsingSyncedHealthData
                        )
                    }
                    Button {
                        viewModel.path.append(.weightForm)
                    } label: {
                        MeasurementLabel(
                            label: "weight",
                            valueString: "93.6 kg",
                            useHealthAppData: viewModel.restingEnergyFormulaUsingSyncedHealthData
                        )
                    }
                    Button {
                        viewModel.path.append(.heightForm)
                    } label: {
                        MeasurementLabel(
                            label: "height",
                            valueString: "177 cm",
                            useHealthAppData: viewModel.restingEnergyFormulaUsingSyncedHealthData
                        )
                    }
                }
            }
            .padding(.bottom, 5)
        }
        
        @ViewBuilder
        var content: some View {
            VStack {
                Group {
                    if let source = viewModel.restingEnergySource {
                        Group {
                            sourceSection
                            switch source {
                            case .healthApp:
                                healthContent
                            case .userEntered:
                                EmptyView()
                            case .formula:
                                formulaContent
                            }
                            energyRow
                        }
                    } else {
                        emptyContent
                    }
                }
            }
        }
        
//        var manualEntryContent: some View {
//            VStack {
//                sourceSection
//                energyRow
//            }
//        }
        
        func tappedManualEntry() {
            viewModel.changeRestingEnergySource(to: .userEntered)
            restingEnergyTextFieldIsFocused = true
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
        
        func tappedFormula() {
            viewModel.changeRestingEnergySource(to: .formula)
        }

        var emptyContent: some View {
            VStack(spacing: 10) {
                emptyButton("Sync with Health app", showHealthAppIcon: true, action: tappedSyncWithHealth)
                emptyButton("Calculate using a Formula", systemImage: "function", action: tappedFormula)
                emptyButton("Let me type it in", systemImage: "keyboard", action: tappedManualEntry)
            }
        }
        
        var healthContent: some View {
            Group {
                if viewModel.restingEnergyFetchStatus == .notAuthorized {
                    permissionRequiredContent
                } else {
                    healthPeriodContent
                }
            }
            .padding()
            .padding(.horizontal)
        }
        
        var energyRow: some View {
            @ViewBuilder
            var health: some View {
                if viewModel.restingEnergyFetchStatus != .notAuthorized {
                    HStack {
                        Spacer()
                        if viewModel.restingEnergyFetchStatus == .fetching {
                            ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                                .frame(width: 25, height: 25)
                                .foregroundColor(.secondary)
                        } else {
                            if viewModel.hasDynamicRestingEnergy {
                                Text("currently")
                                    .font(.subheadline)
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                            Text(viewModel.restingEnergyFormatted)
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .fixedSize(horizontal: true, vertical: false)
                                .matchedGeometryEffect(id: "resting", in: namespace)
                                .if(!viewModel.hasRestingEnergy) { view in
                                    view
                                        .redacted(reason: .placeholder)
                                }
                            Text(viewModel.userEnergyUnit.shortDescription)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            var manualEntry: some View {
                HStack {
                    Spacer()
                    TextField("energy in", text: viewModel.restingEnergyTextFieldStringBinding)
                        .keyboardType(.decimalPad)
                        .focused($restingEnergyTextFieldIsFocused)
                        .fixedSize(horizontal: true, vertical: false)
                        .multilineTextAlignment(.trailing)
//                        .fixedSize(horizontal: true, vertical: false)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .matchedGeometryEffect(id: "resting", in: namespace)
                    Text(viewModel.userEnergyUnit.shortDescription)
                        .foregroundColor(.secondary)
                }
            }
            
            return Group {
                switch viewModel.restingEnergySource {
                case .healthApp:
                    health
                case .formula:
                    health
                case .userEntered:
                    manualEntry
                default:
                    EmptyView()
                }
            }
            .padding(.trailing)
        }
        
        var healthPeriodContent: some View {
            var periodTypeMenu: some View {
               Menu {
                   Picker(selection: viewModel.restingEnergyPeriodBinding, label: EmptyView()) {
                        ForEach(HealthPeriodOption.allCases, id: \.self) {
                            Text($0.pickerDescription).tag($0)
                        }
                    }
                } label: {
                    PickerLabel(
                        viewModel.restingEnergyPeriod.menuDescription,
                        imageColor: Color(hex: "F3DED7"),
                        backgroundGradientTop: Color(hex: AppleHealthTopColorHex),
                        backgroundGradientBottom: Color(hex: AppleHealthBottomColorHex),
                        foregroundColor: .white
                    )
                    .animation(.none, value: viewModel.restingEnergyPeriod)
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
            
            var periodValueMenu: some View {
                Menu {
                    Picker(selection: viewModel.restingEnergyIntervalValueBinding, label: EmptyView()) {
                        ForEach(viewModel.restingEnergyIntervalValues, id: \.self) { quantity in
                            Text("\(quantity)").tag(quantity)
                        }
                    }
                } label: {
                    PickerLabel(
                        "\(viewModel.restingEnergyIntervalValue)",
                        imageColor: Color(hex: "F3DED7"),
                        backgroundGradientTop: Color(hex: AppleHealthTopColorHex),
                        backgroundGradientBottom: Color(hex: AppleHealthBottomColorHex),
                        foregroundColor: .white
                    )
                    .animation(.none, value: viewModel.restingEnergyIntervalValue)
                    .animation(.none, value: viewModel.restingEnergyInterval)
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
            
            var periodIntervalMenu: some View {
                Menu {
                    Picker(selection: viewModel.restingEnergyIntervalBinding, label: EmptyView()) {
                        ForEach(HealthAppInterval.allCases, id: \.self) { interval in
                            Text("\(interval.description)\(viewModel.restingEnergyIntervalValue > 1 ? "s" : "")").tag(interval)
                        }
                    }
                } label: {
                    PickerLabel(
                        "\(viewModel.restingEnergyInterval.description)\(viewModel.restingEnergyIntervalValue > 1 ? "s" : "")",
                        imageColor: Color(hex: "F3DED7"),
                        backgroundGradientTop: Color(hex: AppleHealthTopColorHex),
                        backgroundGradientBottom: Color(hex: AppleHealthBottomColorHex),
                        foregroundColor: .white
                    )
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
        
        @ViewBuilder
        var footer: some View {
            if let string = viewModel.restingEnergyFooterString {
                Text(string)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
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
                .if(viewModel.restingEnergyFooterString == nil) { view in
                    view.padding(.bottom, 10)
                }
                footer
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
    }
}

enum MeasurementSourceOption: CaseIterable {
    case healthApp
    case userEntered
    
    var pickerDescription: String {
        switch self {
        case .healthApp:
            return "Health App"
        case .userEntered:
            return "Let me enter it"
        }
    }
    
    var systemImage: String {
        switch self {
        case .healthApp:
            return "heart.fill"
        case .userEntered:
            return "keyboard"
        }
    }

    var menuDescription: String {
        switch self {
        case .healthApp:
            return "Health App"
        case .userEntered:
            return "Manual Entry"
        }
    }
}

enum LeanBodyMassSourceOption: CaseIterable {
    case healthApp
    case formula
    case fatPercentage
    case userEntered
    
    var pickerDescription: String {
        switch self {
        case .formula:
            return "Formula"
        case .healthApp:
            return "Health App"
        case .fatPercentage:
            return "Fat Percent"
        case .userEntered:
            return "Let me enter it"
        }
    }
    
    var systemImage: String {
        switch self {
        case .healthApp:
            return "heart.fill"
        case .formula:
            return "function"
        case .fatPercentage:
            return "percent"
        case .userEntered:
            return "keyboard"
        }
    }

    var menuDescription: String {
        switch self {
        case .formula:
            return "Formula"
        case .healthApp:
            return "Health App"
        case .fatPercentage:
            return "Convert Fat Percent"
        case .userEntered:
            return "Manual Entry"
        }
    }
}

enum LeanBodyMassFormula: CaseIterable {
    case boer
    case james
    case hume
    
    var pickerDescription: String {
        switch self {
        case .boer:
            return "Boer • 1984"
        case .james:
            return "James • 1976"
        case .hume:
            return "Hume • 1966"
        }
    }
    
    var year: String {
        switch self {
        case .boer:
            return "1984"
        case .james:
            return "1976"
        case .hume:
            return "1966"
        }
    }
    
    var menuDescription: String {
        switch self {
        case .boer:
            return "Boer"
        case .james:
            return "James"
        case .hume:
            return "Hume"
        }
    }
}

func emptyButton(_ string: String, systemImage: String? = nil, showHealthAppIcon: Bool = false, action: (() -> ())? = nil) -> some View {
    Button {
        action?()
    } label: {
        HStack(spacing: 5) {
            if let systemImage {
                Image(systemName: systemImage)
//                    .foregroundColor(.white)
                    .foregroundColor(.white.opacity(0.7))
            } else if showHealthAppIcon {
                appleHealthSymbol
            }
            Text(string)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.white)
//                .foregroundColor(.secondary)
        }
        .frame(minHeight: 30)
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
        .background (
            Capsule(style: .continuous)
                .foregroundColor(.accentColor)
//                .foregroundColor(Color(.secondarySystemFill))
        )
    }
}

enum HealthKitFetchStatus {
    case notFetched
    case fetching
    case fetched
    case notAuthorized
}

extension TDEEForm {
    class ViewModel: ObservableObject {
        let userEnergyUnit: EnergyUnit
        let userWeightUnit: WeightUnit
        let userHeightUnit: HeightUnit

        @Published var path: [Route] = []
        
        @Published var hasAppeared = false
        @Published var activeEnergySource: ActiveEnergySourceOption? = nil
        
        @Published var isEditing = false
        @Published var presentationDetent: PresentationDetent = .height(270)
        @Published var restingEnergySource: RestingEnergySourceOption? = nil
//        @Published var isEditing = true
//        @Published var presentationDetent: PresentationDetent = .large
//        @Published var restingEnergySource: RestingEnergySourceOption? = .formula

        @Published var restingEnergy: Double? = nil
        @Published var restingEnergyTextFieldString: String = ""

        @Published var restingEnergyPeriod: HealthPeriodOption = .average
        @Published var restingEnergyIntervalValue: Int = 1
        @Published var restingEnergyInterval: HealthAppInterval = .week
        
        @Published var restingEnergyFetchStatus: HealthKitFetchStatus = .notFetched
        @Published var restingEnergyUsesHealthMeasurements: Bool = false

        @Published var restingEnergyFormula: RestingEnergyFormula = .katchMcardle
        
        @Published var lbmSource: LeanBodyMassSourceOption? = nil
        @Published var lbmFormula: LeanBodyMassFormula = .boer
        @Published var lbmFetchStatus: HealthKitFetchStatus = .notFetched
        @Published var lbmUsesHealthMeasurements: Bool = false
        @Published var lbm: Double? = nil
        @Published var lbmTextFieldString: String = ""
        @Published var lbmDate: Date? = nil

        @Published var weightSource: MeasurementSourceOption? = nil
        @Published var weightFetchStatus: HealthKitFetchStatus = .notFetched
        @Published var weight: Double? = nil
        @Published var weightTextFieldString: String = ""
        @Published var weightDate: Date? = nil

        @Published var heightSource: MeasurementSourceOption? = nil
        @Published var heightFetchStatus: HealthKitFetchStatus = .notFetched
        @Published var height: Double? = nil
        @Published var heightTextFieldString: String = ""
        @Published var heightDate: Date? = nil

        init(userEnergyUnit: EnergyUnit, userWeightUnit: WeightUnit, userHeightUnit: HeightUnit) {
            self.userEnergyUnit = userEnergyUnit
            self.userWeightUnit = userWeightUnit
            self.userHeightUnit = userHeightUnit
        }
    }
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
