import SwiftUI
import SwiftUISugar

extension TDEEForm {
    var form: some View {
        FormStyledScrollView {
            if viewModel.isEditing {
                editContents
            } else {
                viewContents
            }
        }
    }
    
    var viewContents: some View {
        Group {
            promptSection
            if viewModel.shouldShowSummary {
                arrowSection
                summarySection
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                if viewModel.isDynamic {
                    HStack(alignment: .firstTextBaseline) {
                        appleHealthSymbol
                            .font(.caption2)
                        Text("These components will be continuously updated as new data comes in from the Health App.")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 17)
                }
            }
        }
    }
    
    var editContents: some View {
        Group {
            maintenanceSection
            Text("=")
                .matchedGeometryEffect(id: "equals", in: namespace)
                .font(.title)
                .foregroundColor(Color(.quaternaryLabel))
            restingEnergySection
            Text("+")
                .matchedGeometryEffect(id: "plus", in: namespace)
                .font(.title)
                .foregroundColor(Color(.quaternaryLabel))
            activeEnergySection
//            restingHealthSection
        }
    }
}
