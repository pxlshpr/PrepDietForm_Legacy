import SwiftUI
import SwiftHaptics
import PrepDataTypes
import ActivityIndicatorView
import SwiftUISugar

struct WeightForm: View {
    
    @EnvironmentObject var viewModel: TDEEForm.ViewModel
    @Namespace var namespace
    @FocusState var isFocused: Bool
    
    var content: some View {
        VStack {
            Group {
                if let source = viewModel.weightSource {
                    Group {
                        sourceSection
                        switch source {
                        case .healthApp:
//                            healthContent
                            EmptyView()
                        case .userEntered:
                            EmptyView()
                        }
                        bottomRow
                    }
                } else {
                    emptyContent
                }
            }
        }
    }

    func tappedSyncWithHealth() {
        viewModel.changeWeightSource(to: .healthApp)
    }
    
    func tappedManualEntry() {
        viewModel.changeWeightSource(to: .userEntered)
        isFocused = true
    }
    
    var emptyContent: some View {
        VStack(spacing: 10) {
            emptyButton("Sync with Health app", showHealthAppIcon: true, action: tappedSyncWithHealth)
            emptyButton("Let me type it in", systemImage: "keyboard", action: tappedManualEntry)
        }
    }

    var footer: some View {
        var string: String {
            switch viewModel.weightSource {
            case .userEntered:
                return "You will need to ensure your weight is kept up to date for an accurate calculation."
            case .healthApp:
                return "Your weight will be kept in sync with the Health App."
            default:
                return "Choose to sync your weight with the Health App or enter it yourself."
            }
        }
        return Text(string)
    }
    
    var bottomRow: some View {
        @ViewBuilder
        var health: some View {
            if viewModel.weightFetchStatus != .notAuthorized {
                HStack {
                    Spacer()
                    if viewModel.weightFetchStatus == .fetching {
                        ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                            .frame(width: 25, height: 25)
                            .foregroundColor(.secondary)
                    } else {
                        if let date = viewModel.weightDate {
                            Text("as of \(date.tdeeFormat)")
                                .font(.subheadline)
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        Text(viewModel.weightFormatted)
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .matchedGeometryEffect(id: "weight", in: namespace)
                            .if(!viewModel.hasWeight) { view in
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
                "weight in"
            }
            var binding: Binding<String> {
                viewModel.weightTextFieldStringBinding
            }
            var unitString: String {
                viewModel.userWeightUnit.shortDescription
            }
            return HStack {
                Spacer()
                TextField(prompt, text: binding)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .multilineTextAlignment(.trailing)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .matchedGeometryEffect(id: "weight", in: namespace)
                Text(unitString)
                    .foregroundColor(.secondary)
            }
        }
        
        return Group {
            switch viewModel.weightSource {
            case .healthApp:
                health
            case .userEntered:
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
                Picker(selection: viewModel.weightSourceBinding, label: EmptyView()) {
                    ForEach(MeasurementSourceOption.allCases, id: \.self) {
                        Label($0.pickerDescription, systemImage: $0.systemImage).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    HStack {
                        if viewModel.weightSource == .healthApp {
                            appleHealthSymbol
                        } else {
                            if let systemImage = viewModel.weightSource?.systemImage {
                                Image(systemName: systemImage)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Text(viewModel.weightSource?.menuDescription ?? "")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .foregroundColor(.secondary)
                .animation(.none, value: viewModel.weightSource)
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
    }
    
    func weightSourceChanged(to newSource: MeasurementSourceOption?) {
        switch newSource {
        case .userEntered:
            isFocused = true
        default:
            break
        }
    }
 
    var header: some View {
        Text("Weight")
    }
    
    var body: some View {
        FormStyledSection(header: header, footer: footer) {
            content
        }
        .onChange(of: viewModel.weightSource, perform: weightSourceChanged)
    }
}
