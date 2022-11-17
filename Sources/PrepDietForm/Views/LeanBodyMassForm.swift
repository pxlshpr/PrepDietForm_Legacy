import SwiftUI
import SwiftHaptics
import PrepDataTypes
import ActivityIndicatorView
import SwiftUISugar

struct LeanBodyMassForm: View {
    
    @EnvironmentObject var viewModel: TDEEForm.ViewModel
    @Namespace var namespace
    @FocusState var isFocused: Bool
    
    var content: some View {
        VStack {
            Group {
                if let source = viewModel.lbmSource {
                    Group {
                        sourceSection
                        switch source {
                        case .healthApp:
//                            healthContent
                            EmptyView()
                        case .userEntered:
                            EmptyView()
                        case .fatPercentage:
                            EmptyView()
                        case .formula:
                            formulaContent
                        }
                        bottomRow
                    }
                } else {
                    emptyContent
                }
            }
        }
    }

    var formulaContent: some View {
        var formulaRow: some View {
            var menu: some View {
                Menu {
                    Picker(selection: viewModel.lbmFormulaBinding, label: EmptyView()) {
                        ForEach(LeanBodyMassFormula.allCases, id: \.self) {
                            Text($0.pickerDescription).tag($0)
                        }
                    }
                } label: {
                    PickerLabel(
                        viewModel.lbmFormula.year,
                        prefix: viewModel.lbmFormula.menuDescription,
                        foregroundColor: .secondary,
                        prefixColor: .primary
                    )
                    .animation(.none, value: viewModel.lbmFormula)
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
            return HStack {
                HStack {
                    Text("Using")
                        .foregroundColor(.secondary)
                    menu
                }
            }
            .padding(.top, 8)
        }
        
        return VStack {
            formulaRow
                .padding(.bottom)
        }
    }
    
    func tappedSyncWithHealth() {
        viewModel.changeLBMSource(to: .healthApp)
    }
    
    func tappedFormula() {
        viewModel.changeLBMSource(to: .formula)
    }
    
    func tappedFatPercentage() {
        viewModel.changeLBMSource(to: .fatPercentage)
        isFocused = true
    }
    
    func tappedManualEntry() {
        viewModel.changeLBMSource(to: .userEntered)
        isFocused = true
    }
    
    var emptyContent: some View {
        VStack(spacing: 10) {
            emptyButton("Sync with Health app", showHealthAppIcon: true, action: tappedSyncWithHealth)
            emptyButton("Calculate using a Formula", systemImage: "function", action: tappedFormula)
            emptyButton("Convert Fat Percentage", systemImage: "percent", action: tappedFatPercentage)
            emptyButton("Let me type it in", systemImage: "keyboard", action: tappedManualEntry)
        }
    }

    var infoSection: some View {
        FormStyledSection {
            Text("Lean body mass is the weight of your body minus your body fat (adipose tissue).")
                .foregroundColor(.secondary)
        }
    }
    
    var bottomRow: some View {
        @ViewBuilder
        var health: some View {
            if viewModel.lbmFetchStatus != .notAuthorized {
                HStack {
                    Spacer()
                    if viewModel.lbmFetchStatus == .fetching {
                        ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                            .frame(width: 25, height: 25)
                            .foregroundColor(.secondary)
                    } else {
                        if viewModel.hasDynamicLeanBodyMass {
                            Text("currently")
                                .font(.subheadline)
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        Text(viewModel.lbmFormatted)
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .matchedGeometryEffect(id: "lbm", in: namespace)
                            .if(!viewModel.hasLeanBodyMass) { view in
                                view
                                    .redacted(reason: .placeholder)
                            }
                        Text(viewModel.userWeightUnit.shortDescription)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        
        var manualEntry: some View {
            var prompt: String {
                viewModel.lbmSource == .userEntered ? "lead body mass in" : "fat percent"
            }
            var binding: Binding<String> {
                viewModel.lbmTextFieldStringBinding
            }
            var unitString: String {
                viewModel.lbmSource == .fatPercentage ? "%" : viewModel.userWeightUnit.shortDescription
            }
            return HStack {
                Spacer()
                TextField(prompt, text: binding)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .multilineTextAlignment(.trailing)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .matchedGeometryEffect(id: "lbm", in: namespace)
                Text(unitString)
                    .foregroundColor(.secondary)
            }
        }
        
        return Group {
            switch viewModel.lbmSource {
            case .healthApp:
                health
            case .formula:
                EmptyView()
            case .userEntered:
                manualEntry
            case .fatPercentage:
                manualEntry
            default:
                EmptyView()
            }
        }
        .padding(.trailing)
    }
    
    var sourceSection: some View {
        var sourceMenu: some View {
            Menu {
                Picker(selection: viewModel.lbmSourceBinding, label: EmptyView()) {
                    ForEach(LeanBodyMassSourceOption.allCases, id: \.self) {
                        Label($0.pickerDescription, systemImage: $0.systemImage).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    HStack {
                        if viewModel.lbmSource == .healthApp {
                            appleHealthSymbol
                        } else {
                            if let systemImage = viewModel.lbmSource?.systemImage {
                                Image(systemName: systemImage)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Text(viewModel.lbmSource?.menuDescription ?? "")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .foregroundColor(.secondary)
                .animation(.none, value: viewModel.lbmSource)
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
//        .padding(.horizontal, 17)
    }
    
    func lbmSourceChanged(to newSource: LeanBodyMassSourceOption?) {
        switch newSource {
        case .userEntered:
            isFocused = true
        default:
            break
        }
    }
    
    var calculatedSection: some View {
        var headerRow: some View {
            HStack {
                Image(systemName: "function")
                Text("Calculated")
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.secondary)
//            .fixedSize(horizontal: true, vertical: false)
        }
        
        var lbmRow: some View {
            HStack {
                Spacer()
//                Text("calculated")
//                    .font(.subheadline)
//                    .foregroundColor(Color(.tertiaryLabel))
                Text(viewModel.calculatedLBMFormatted)
                    .foregroundColor(.secondary)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .if(!viewModel.hasLeanBodyMass) { view in
                        view
                            .redacted(reason: .placeholder)
                    }
                Text(viewModel.userWeightUnit.shortDescription)
                    .foregroundColor(.secondary)
            }
        }

        return FormStyledSection {
            VStack {
                headerRow
                lbmRow
            }
        }
    }
 
    var footer: some View {
        var string: String {
            switch viewModel.lbmSource {
            case .userEntered:
                return "You will need to ensure your lean body mass is kept up to date for an accurate calculation."
            case .healthApp:
                return "Your lean body mass will be kept in sync with the Health App."
            case .formula:
                return "Use a formula to calculate your lean body mass."
            case .fatPercentage:
                return "Enter your fat percentage to calculate your lean body mass."
            default:
                return "Choose how you want to enter your lean body mass."
            }
        }
        return Text(string)
    }
    
    var percentageSupplementaryContent: some View {
        Group {
            Text("of")
                .font(.title)
                .foregroundColor(Color(.quaternaryLabel))
            WeightSection()
            Text("=")
                .font(.title)
                .foregroundColor(Color(.quaternaryLabel))
            calculatedSection
        }
    }
    
    var formulaSupplementaryContent: some View {
        Group {
            Text("with")
                .font(.title)
                .foregroundColor(Color(.quaternaryLabel))
            WeightSection()
            HeightSection()
            Text("=")
                .font(.title)
                .foregroundColor(Color(.quaternaryLabel))
            calculatedSection
        }
    }
    
    @ViewBuilder
    var supplementaryContent: some View {
        switch viewModel.lbmSource {
        case .fatPercentage:
            percentageSupplementaryContent
        case .formula:
            formulaSupplementaryContent
        default:
            EmptyView()
        }
    }
    
    var body: some View {
        FormStyledScrollView {
            infoSection
            FormStyledSection(footer: footer) {
                content
            }
            supplementaryContent
        }
        .navigationTitle("Lean Body Mass")
        .onChange(of: viewModel.lbmSource, perform: lbmSourceChanged)
    }
}
