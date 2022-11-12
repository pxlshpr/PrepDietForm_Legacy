import SwiftUI
import SwiftUISugar
import SwiftHaptics

public struct GoalSetForm: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: ViewModel
    @State var showingNutrientsPicker: Bool = false
    @State var showingEmojiPicker = false
    @State var showingCalculated = false
    
    public init(isMealProfile: Bool, existingGoalSet: GoalSet? = nil) {
        let viewModel = ViewModel(
            isMealProfile: isMealProfile,
            existingGoalSet: existingGoalSet
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            content
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar { trailingContent }
            .toolbar { leadingContent }
            .sheet(isPresented: $showingNutrientsPicker) { nutrientsPicker }
            .sheet(isPresented: $showingEmojiPicker) { emojiPicker }
        }
    }
    
    var title: String {
        let typeName = viewModel.isMealProfile ? "Meal Profile": "Diet"
        return viewModel.existingGoalSet == nil ? "New \(typeName)" : typeName
    }
    
    var content: some View {
        scrollView
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                detailsCell
                titleCell("Goals")
                emptyContent
                energyCell
                macroCells
                microCells
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    var energyCell: some View {
        if let energy = viewModel.energyGoal {
            cell(for: energy)
        }
    }
    
    func cell(for goal: GoalViewModel) -> some View {
        NavigationLink {
            goalForm(for: goal)
        } label: {
            GoalCell(goal: goal)
        }
    }
    
    @ViewBuilder
    var macroCells: some View {
        if !viewModel.macroGoals.isEmpty {
            Group {
                subtitleCell("Macros")
                ForEach(viewModel.macroGoals, id: \.self) {
                    cell(for: $0)
                }
            }
        }
    }
    
    @ViewBuilder
    var microCells: some View {
        if !viewModel.microGoals.isEmpty {
            Group {
                subtitleCell("Micronutrients")
                ForEach(viewModel.microGoals, id: \.self) {
                    cell(for: $0)
                }
            }
        }
    }
    
    var detailsCell: some View {
        HStack {
            emojiButton
            nameTextField
            Spacer()
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.bottom, 10)
    }
    
    var emojiButton: some View {
        Button {
            showingEmojiPicker = true
        } label: {
            Text(viewModel.emoji)
                .font(.system(size: 50))
        }
    }
    
    @ViewBuilder
    var nameTextField: some View {
        TextField("Enter a Name", text: $viewModel.name)
            .font(.title3)
            .multilineTextAlignment(.leading)
    }
    
    func titleCell(_ title: String) -> some View {
        Group {
            Spacer().frame(height: 15)
            HStack {
                Spacer().frame(width: 3)
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                Spacer()
            }
            Spacer().frame(height: 7)
        }
    }
    
    func subtitleCell(_ title: String) -> some View {
        Group {
            Spacer().frame(height: 5)
            HStack {
                Spacer().frame(width: 3)
                Text(title)
                    .font(.headline)
//                    .bold()
                    .foregroundColor(.secondary)
                Spacer()
            }
            Spacer().frame(height: 7)
        }
    }
    
    var leadingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                Haptics.feedback(style: .soft)
                dismiss()
            } label: {
                closeButtonLabel
            }
        }
    }
}
