import SwiftUI
import SwiftUISugar

extension EnergyForm {
    var body: some View {
        FormStyledScrollView {
            HStack(spacing: 0) {
                lowerBoundSection
                upperBoundSection
            }
            unitSection
            equivalentSection
        }
        .navigationTitle("Energy")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: pickedMealEnergyGoalType, perform: mealEnergyGoalChanged)
        .onChange(of: pickedDietEnergyGoalType, perform: dietEnergyGoalChanged)
        .onChange(of: pickedDelta, perform: deltaChanged)
        .onAppear(perform: appeared)
        .sheet(isPresented: $showingTDEEForm) { tdeeForm }
    }
    
    var unitSection: some View {
        FormStyledSection {
            FlowView(alignment: .leading, spacing: 10, padding: 37) {
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
                    typePicker
                    deltaPicker
                    tdeeButton
//                }
//                .padding(.horizontal, 10)
            }
//            .id(refreshBool) /// Needed to mitigate the buttons being slightly out of place once we set them in `onAppear`
            .frame(maxWidth: .infinity)
//            .frame(height: 50)
        }
    }
    
    var tdeeForm: some View {
        TDEEForm { profile in
            viewModel.currentTDEEProfile = profile
        }
    }
    
    @ViewBuilder
    var tdeeButton: some View {
        if shouldShowEnergyDeltaElements {
            Button {
                showingTDEEForm = true
            } label: {
                if let profile = viewModel.currentTDEEProfile {
                    PickerLabel(
                        profile.formattedTDEEWithUnit,
//                        prefix: "maintenance",
//                        systemImage: "flame.fill",
                        imageColor: Color(.secondaryLabel),
                        imageScale: .large
                    )
                } else {
                    PickerLabel(
                        "maintenance",
//                        prefix: "set",
//                        systemImage: "flame.fill",
                        imageColor: Color.white.opacity(0.75),
                        backgroundColor: .accentColor,
                        foregroundColor: .white,
                        prefixColor: Color.white.opacity(0.75),
                        imageScale: .large
                    )
                }
            }
        }
    }
    
}
