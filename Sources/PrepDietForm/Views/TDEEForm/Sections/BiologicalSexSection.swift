import SwiftUI
import SwiftHaptics
import PrepDataTypes
import ActivityIndicatorView
import SwiftUISugar
import HealthKit

struct BiologicalSexSection: View {
    
    @EnvironmentObject var viewModel: TDEEForm.ViewModel
    @Namespace var namespace
    
    var content: some View {
        VStack {
            Group {
                if let source = viewModel.sexSource {
                    Group {
                        sourceSection
                        switch source {
                        case .healthApp:
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
        viewModel.changeSexSource(to: .healthApp)
    }
    
    func tappedManualEntry() {
        viewModel.changeSexSource(to: .userEntered)
    }
    
    var emptyContent: some View {
        VStack(spacing: 10) {
            emptyButton("Sync with Health app", showHealthAppIcon: true, action: tappedSyncWithHealth)
            emptyButton("Let me specify it", systemImage: "hand.tap", action: tappedManualEntry)
        }
    }

    @ViewBuilder
    var footer: some View {
        switch viewModel.sexSource {
        case .userEntered:
            EmptyView()
        case .healthApp:
            EmptyView()
        default:
            Text("This is the biological sex used in the calculation. Choose to import it from the Health App or pick it yourself.")
        }
    }
    
    var bottomRow: some View {
        @ViewBuilder
        var health: some View {
            if viewModel.sexFetchStatus != .notAuthorized {
                HStack {
                    Spacer()
                    if viewModel.sexFetchStatus == .fetching {
                        ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                            .frame(width: 25, height: 25)
                            .foregroundColor(.secondary)
                    } else {
                        Text(viewModel.sexFormatted)
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .matchedGeometryEffect(id: "sex", in: namespace)
                            .if(!viewModel.hasSex) { view in
                                view
                                    .redacted(reason: .placeholder)
                            }
                    }
                }
            }
        }
        
        var manualEntry: some View {
            var picker: some View {
                Menu {
                    Picker(selection: viewModel.sexPickerBinding, label: EmptyView()) {
                        Text("female").tag(HKBiologicalSex.female)
                        Text("male").tag(HKBiologicalSex.male)
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(viewModel.sexFormatted)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundColor(.accentColor)
                    .matchedGeometryEffect(id: "sex", in: namespace)
                    .animation(.none, value: viewModel.sex)
                    .fixedSize(horizontal: true, vertical: true)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
            }
            return HStack {
                Spacer()
                picker
            }
        }
        
        return Group {
            switch viewModel.sexSource {
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
                Picker(selection: viewModel.sexSourceBinding, label: EmptyView()) {
                    ForEach(MeasurementSourceOption.allCases, id: \.self) {
                        Label($0.pickerDescription, systemImage: $0.systemImage).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    HStack {
                        if viewModel.sexSource == .healthApp {
                            appleHealthSymbol
                        } else {
                            if let systemImage = viewModel.sexSource?.systemImage {
                                Image(systemName: systemImage)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Text(viewModel.sexSource?.menuDescription ?? "")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .foregroundColor(.secondary)
                .animation(.none, value: viewModel.sexSource)
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
    
    func sexSourceChanged(to newSource: MeasurementSourceOption?) {
        switch newSource {
        case .userEntered:
            break
        default:
            break
        }
    }
 
    var header: some View {
        Text("Biological Sex")
    }
    
    var body: some View {
        FormStyledSection(header: header, footer: footer) {
            content
        }
        .onChange(of: viewModel.sexSource, perform: sexSourceChanged)
    }
}
