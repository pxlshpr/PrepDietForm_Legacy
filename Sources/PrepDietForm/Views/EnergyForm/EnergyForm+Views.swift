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
        FormStyledSection(header: Text("Unit"), horizontalPadding: 0, verticalPadding: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    typePicker
                    deltaPicker
                    tdeeButton
                }
                .padding(.horizontal, 10)
            }
            .id(refreshBool) /// Needed to mitigate the buttons being slightly out of place once we set them in `onAppear`
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
    }
    
    var tdeeForm: some View {
        TDEEForm { profile in
            print("We here boi")
        }
    }
}
