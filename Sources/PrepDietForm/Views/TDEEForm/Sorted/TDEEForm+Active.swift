import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes

extension TDEEForm {
    
    var activeEnergySection: some View {
        
        @ViewBuilder
        var content: some View {
            if viewModel.activeEnergySource == nil {
                emptyContent
            } else {
                filledContent
            }
        }
        
        var filledContent: some View {
            VStack(spacing: 5) {
                HStack {
                    HStack(spacing: 5) {
                        appleHealthSymbol
                            .matchedGeometryEffect(id: "active-health-icon", in: namespace)
                        Text("Health App")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(Color(.tertiaryLabel))
                            .imageScale(.small)
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    HStack {
                        Text("Use")
                            .foregroundColor(.secondary)
                        PickerLabel("previous day's value")
                    }
                    Spacer()
                }
                .padding(.top)
                .padding(.bottom)
                HStack {
                    Spacer()
                    Text("1,428")
                        .matchedGeometryEffect(id: "active", in: namespace)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                    Text("kcal")
                        .foregroundColor(.secondary)
                }
            }
        }
        
        func tappedSyncWithHealth() {
//            Task(priority: .high) {
//                await HealthKitManager.shared.requestPermission(for: .activeEnergyBurned)
//            }
        }
        
        var emptyContent: some View {
            VStack(spacing: 10) {
                emptyButton("Sync with Health App", showHealthAppIcon: true, action: tappedSyncWithHealth)
                emptyButton("Apply Activity Multiplier", systemImage: "dial.medium.fill")
                emptyButton("Let me type it in", systemImage: "keyboard")
            }
        }
        
        return VStack(spacing: 7) {
            activeHeader
                .foregroundColor(Color(.secondaryLabel))
                .font(.footnote)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            content
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 17)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(.secondarySystemGroupedBackground))
                        .matchedGeometryEffect(id: "active-bg", in: namespace)
                )
                .padding(.bottom, 10)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}
