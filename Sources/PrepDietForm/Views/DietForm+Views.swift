import SwiftUI
import PrepDataTypes
import PrepViews
import SwiftHaptics

extension DietForm {
    var nutrientsPicker: some View {
        NutrientsPicker(
            supportsEnergyAndMacros: true,
            shouldShowEnergy: !viewModel.goals.containsEnergy,
            shouldShowMacro: shouldShowMacro,
            hasUnusedMicros: hasUnusedMicros,
            hasMicronutrient: hasMicronutrient,
            didAddNutrients: viewModel.didAddNutrients
        )
    }
    
    @ViewBuilder
    func goalForm(for goal: GoalViewModel) -> some View {
        if goal.type.isEnergy {
            EnergyGoalForm(goal: goal)
                .environmentObject(viewModel)
        } else {
            Color.blue
        }
    }
}

extension DietForm {
    var emptyContent: some View {
        VStack {
            Spacer()
            ZStack {
                Color(.systemGroupedBackground)
                VStack {
                    Text("Give this diet a name and add nutrients to set goals for")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(.tertiaryLabel))
                    Button {
                        Haptics.feedback(style: .soft)
                        showingNutrientsPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Nutrients")
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
                }
                .padding()
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .foregroundColor(Color(.quaternarySystemFill))
                )
                .padding(.horizontal, 50)
                .offset(y: 0)
            }
            Spacer()
//            addNutrientsButton
        }
//        .padding(.horizontal, 20)
    }
    
    var addNutrientsButton: some View {
        Button {
            showingNutrientsPicker = true
        } label: {
            Label("Add Nutrients", systemImage: "plus.circle.fill")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.accentColor)
                .padding(.horizontal, 16)
                .padding(.bottom, 13)
                .padding(.top, 13)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
                .padding(.bottom, 10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }
}
