import SwiftUI
import SwiftUISugar
import SwiftHaptics

public struct GoalSetForm: View {
    
    enum Route: Hashable {
        case goal(GoalViewModel)
    }
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: ViewModel
    @State var showingNutrientsPicker: Bool = false
    @State var showingEmojiPicker = false
    
    @State var showingEquivalentValuesToggle: Bool
    @State var showingEquivalentValues = false

    @FocusState var isFocused: Bool
    
    public init(isMealProfile: Bool, existingGoalSet: GoalSet? = nil, bodyProfile: BodyProfile? = nil, presentedGoalId: UUID? = nil) {
        let viewModel = ViewModel(
            userUnits: .standard,
            isMealProfile: isMealProfile,
            existingGoalSet: existingGoalSet,
            bodyProfile: bodyProfile,
            presentedGoalId: presentedGoalId
        )
        _viewModel = StateObject(wrappedValue: viewModel)
        
        _showingEquivalentValuesToggle = State(initialValue: viewModel.containsGoalWithEquivalentValues)
    }
    
    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            content
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar { trailingContent }
            .toolbar { leadingContent }
            .sheet(isPresented: $showingNutrientsPicker) { nutrientsPicker }
            .sheet(isPresented: $showingEmojiPicker) { emojiPicker }
            .navigationDestination(for: Route.self, destination: navigationDestination)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.containsGoalWithEquivalentValues, perform: containsGoalWithEquivalentValuesChanged)
        }
    }
    
    func containsGoalWithEquivalentValuesChanged(to newValue: Bool) {
        withAnimation {
            showingEquivalentValuesToggle = newValue
        }
    }
    
    @ViewBuilder
    func navigationDestination(for route: Route) -> some View {
        switch route {
        case .goal(let goalViewModel):
            goalForm(for: goalViewModel)
        }
    }
    
    var title: String {
        let typeName = viewModel.isMealProfile ? "Meal Type": "Diet"
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
                dynamicInfoContent
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
    
    func cell(for goalViewModel: GoalViewModel) -> some View {
//        NavigationLink {
//            goalForm(for: goal)
//        } label: {
//            GoalCell(goal: goal, showingEquivalentValues: $showingEquivalentValues)
//        }
        Button {
            isFocused = false
            viewModel.path.append(.goal(goalViewModel))
        } label: {
            GoalCell(
                goal: goalViewModel,
                showingEquivalentValues: $showingEquivalentValues
            )
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
    
    @ViewBuilder
    var dynamicInfoContent: some View {
        if viewModel.containsDynamicGoal {
            HStack(alignment: .firstTextBaseline) {
                appleHealthBolt
                    .imageScale(.small)
                Text("These are dynamic goals and will automatically update when new data is synced from the Health App.")
            }
            .font(.footnote)
            .foregroundColor(Color(.secondaryLabel))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .padding(.bottom, 13)
            .padding(.top, 13)
            .background(Color(.secondarySystemGroupedBackground).opacity(0))
            .cornerRadius(10)
            .padding(.bottom, 10)
        }
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
            .focused($isFocused)
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
                equivalentValuesToggle
            }
            Spacer().frame(height: 7)
        }
    }
    
    var equivalentValuesToggle: some View {
        let binding = Binding<Bool>(
            get: { showingEquivalentValues },
            set: { newValue in
                Haptics.feedback(style: .rigid)
                withAnimation {
                    showingEquivalentValues = newValue
                }
            }
        )
        return Group {
            if showingEquivalentValuesToggle {
                Toggle(isOn: binding) {
                    Label("Calculated Goals", systemImage: "equal.square")
//                    Text("Calculated Goals")
                        .font(.subheadline)
                }
                .toggleStyle(.button)
            } else {
                Spacer()
            }
        }
        .frame(height: 28)
    }
//    var calculatedButton: some View {
//        Button {
//            Haptics.feedback(style: .rigid)
//            withAnimation {
//                showingEquivalentValues.toggle()
//            }
//        } label: {
//            Image(systemName: "equal.square\(showingEquivalentValues ? ".fill" : "")")
//        }
//    }
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
