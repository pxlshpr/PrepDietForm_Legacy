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
                            weightRow
                            syncWithHealthAppToggle
                        case .formula:
                            EmptyView()
//                            formulaContent
                        }
                        bottomRow
                    }
                } else {
                    emptyContent
                }
            }
        }
    }

    var weightRow: some View {
        var formulaMenu: some View {
            Button {
                viewModel.path.append(.weightForm)
            } label: {
                MeasurementLabel(
                    label: "weight",
                    valueString: viewModel.weightFormattedWithUnit,
                    useHealthAppData: viewModel.weightSource == .healthApp
                )
            }
        }
        return HStack {
            HStack {
                Text("of")
                    .foregroundColor(.secondary)
                formulaMenu
            }
        }
        .padding(.top, 8)
    }
    
    var syncWithHealthAppToggle: some View {
        let binding = Binding<Bool>(
            get: { viewModel.weightSource == .healthApp },
            set: { isHealthApp in
                viewModel.changeWeightSource(to: isHealthApp ? .healthApp : .userEntered)
            }
        )
        return Toggle(isOn: binding) {
            HStack {
                appleHealthSymbol
                    .matchedGeometryEffect(id: "resting-health-icon", in: namespace)
                Text("Sync\(viewModel.weightSource == .healthApp ? "ed" : "") with Health App")
            }
        }
        .toggleStyle(.button)
    }

    func tappedSyncWithHealth() {
        
    }
    
    func tappedFormula() {
        
    }
    
    func tappedFatPercentage() {
        viewModel.changeLBMSoruce(to: .fatPercentage)
        isFocused = true
    }
    
    func tappedManualEntry() {
        viewModel.changeLBMSoruce(to: .userEntered)
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

    var footer: some View {
        Text("Lean body mass is the weight of your body minus your body fat (adipose tissue).")
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
                        Text(viewModel.restingEnergyFormatted)
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
    
    func lbmSourceChange(to newSource: LeanBodyMassSourceOption?) {
        switch newSource {
        case .userEntered:
            isFocused = true
        default:
            break
        }
    }
 
    var body: some View {
        FormStyledScrollView {
            FormStyledSection(footer: footer) {
                content
            }
        }
        .navigationTitle("Lean Body Mass")
        .onChange(of: viewModel.lbmSource, perform: lbmSourceChange)
    }
}
