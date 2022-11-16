import SwiftUI

extension TDEEForm {
    
    var maintenanceSection: some View {
        
        var content: some View {

            var filled: some View {
                VStack {
                    HStack {
                        Text("3,204")
                            .fixedSize(horizontal: true, vertical: false)
                            .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                            .matchedGeometryEffect(id: "maintenance", in: namespace)
                        Text("kcal")
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing)
                }
            }
            
            var empty: some View {
                Text("Set your resting and active energies to determine this")
                    .foregroundColor(Color(.tertiaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.vertical)
            }
            
            return Group {
                if viewModel.maintenanceEnergy != nil {
                    filled
                } else {
                    empty
                }
            }
        }
        
        var header: some View {
            var empty: some View {
                HStack {
                    Image(systemName: "flame.fill")
                        .matchedGeometryEffect(id: "maintenance-header-icon", in: namespace)
                    Text("Setup Maintenance Calories")
                        .fixedSize(horizontal: true, vertical: false)
                        .matchedGeometryEffect(id: "maintenance-header-title", in: namespace)
                }
            }
            
            var filled: some View {
                HStack {
                    Image(systemName: "flame.fill")
                        .matchedGeometryEffect(id: "maintenance-header-icon", in: namespace)
                    Text("Maintenance Energy")
                }
            }
            return Group {
                if viewModel.maintenanceEnergy == nil {
                    empty
                } else {
                    filled
                }
            }
        }
        
        return Group {
            VStack(spacing: 7) {
                header
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
                            .matchedGeometryEffect(id: "maintenance-bg", in: namespace)
                    )
                viewModel.maintenanceEnergyFooterText
                    .matchedGeometryEffect(id: "maintenance-footer", in: namespace)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
}
