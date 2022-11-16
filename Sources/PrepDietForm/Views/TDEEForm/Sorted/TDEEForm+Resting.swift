import SwiftUI
import SwiftHaptics
import PrepDataTypes
import ActivityIndicatorView
import SwiftUISugar

//func label(_ label: String, _ valueString: String) -> some View {

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
            foregroundColor: foregroundColor,
            prefixColor: prefixColor,
            infiniteMaxHeight: false
        )
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
        return useHealthAppData ? Color(.secondaryLabel) : Color.primary
    }
    var prefixColor: Color {
        useHealthAppData ? Color(.tertiaryLabel) : Color.secondary
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

extension TDEEForm {
    
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
                useHealthAppToggle
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
                            useHealthAppData: useHealthAppData
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
                            useHealthAppData: useHealthAppData
                        )
                    }
                    Button {
                        viewModel.path.append(.weightForm)
                    } label: {
                        MeasurementLabel(
                            label: "weight",
                            valueString: "93.6 kg",
                            useHealthAppData: useHealthAppData
                        )
                    }
                    Button {
                        viewModel.path.append(.heightForm)
                    } label: {
                        MeasurementLabel(
                            label: "height",
                            valueString: "177 cm",
                            useHealthAppData: useHealthAppData
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
                    EmptyView()
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
                    PickerLabel(viewModel.restingEnergyPeriod.menuDescription)
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
                    PickerLabel("\(viewModel.restingEnergyIntervalValue)")
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
    case formula
    case healthApp
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
    
    var menuDescription: String {
        switch self {
        case .boer:
            return "Boer (1984)"
        case .james:
            return "James (1976)"
        case .hume:
            return "Hume (1966)"
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
                    .foregroundColor(.secondary)
            } else if showHealthAppIcon {
                appleHealthSymbol
            }
            Text(string)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.white)
//                .foregroundColor(.secondary)
        }
        .frame(minHeight: 35)
        .padding(.horizontal, 20)
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
