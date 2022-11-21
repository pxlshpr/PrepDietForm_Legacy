import SwiftUI
import PrepDataTypes
import PrepViews
import SwiftHaptics
import EmojiPicker

extension GoalSetForm {
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
    
    var emojiPicker: some View {
        EmojiPicker(
            focusOnAppear: false,
            includeCancelButton: true) { emoji in
                Haptics.successFeedback()
                showingEmojiPicker = false
                viewModel.emoji = emoji
            }
    }
    
    @ViewBuilder
    func goalForm(for goal: GoalViewModel) -> some View {
        if goal.type.isEnergy {
            EnergyForm(goal: goal)
                .environmentObject(viewModel)
        } else if goal.type.isMacro {
            MacroForm(goal: goal)
                .environmentObject(viewModel)
        } else {
            Color.blue
        }
    }
    
    
    var trailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            HStack {
//                calculatedButton
                addButton
            }
        }
    }
    
    //TODO: Get view model to only show this if we have goals that aren't fixed
    var calculatedButton: some View {
        Button {
            Haptics.feedback(style: .rigid)
            withAnimation {
                showingEquivalentValues.toggle()
            }
        } label: {
            Image(systemName: "equal.square\(showingEquivalentValues ? ".fill" : "")")
        }
    }
    
    @ViewBuilder
    var addButton: some View {
        if !viewModel.goals.isEmpty {
            Button {
                showingNutrientsPicker = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    @ViewBuilder
    var emptyContent: some View {
        if viewModel.goals.isEmpty {
            emptyPrompt
        }
    }

    var emptyPrompt: some View {
        VStack {
            Text("You haven't added any goals yet")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.tertiaryLabel))
            Button {
                Haptics.feedback(style: .soft)
                showingNutrientsPicker = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Goals")
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
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundColor(Color(.quaternarySystemFill))
        )
        .cornerRadius(10)
        .padding(.bottom, 10)
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
