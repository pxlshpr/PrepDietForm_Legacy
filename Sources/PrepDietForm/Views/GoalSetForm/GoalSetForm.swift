import SwiftUI
import SwiftUISugar
import SwiftHaptics

public enum GoalSetFormRoute: Hashable {
    case goal(GoalViewModel)
}

//extension GoalSetForm {
//    public class ViewModel: ObservableObject {
//        @Published var nutrientTDEEFormViewModel: TDEEForm.ViewModel
//        @Published var path: [GoalSetFormRoute] = []
//        let existingGoalSet: GoalSet?
//
//        init(
//            userUnits: UserUnits,
//            bodyProfile: BodyProfile?,
//            presentedGoalId: UUID? = nil,
//            existingGoalSet: GoalSet?
//        ) {
//            self.existingGoalSet = existingGoalSet
//
//            self.nutrientTDEEFormViewModel = TDEEForm.ViewModel(
//                existingProfile: bodyProfile,
//                userUnits: userUnits
//            )
//
//            self.path = []
//            //TODO: Bring this back
////            if let presentedGoalId, let goalViewModel = goals.first(where: { $0.id == presentedGoalId }) {
////                self.path = [.goal(goalViewModel)]
////            }
//        }
//    }
//
//    func resetNutrientTDEEFormViewModel() {
//        setNutrientTDEEFormViewModel(with: bodyProfile)
//    }
//
//    func setNutrientTDEEFormViewModel(with bodyProfile: BodyProfile?) {
//        nutrientTDEEFormViewModel = TDEEForm.ViewModel(existingProfile: bodyProfile, userUnits: userUnits)
//    }
//
//    func setBodyProfile(_ bodyProfile: BodyProfile) {
//        /// in addition to setting the current body Profile, we also update the view model (TDEEForm.ViewModel) we have  in GoalSetViewModel (or at least the relevant fields for weight and lbm)
//        self.bodyProfile = bodyProfile
//        setNutrientTDEEFormViewModel(with: bodyProfile)
//    }
//}

public struct GoalSetForm: View {
        
    @Environment(\.dismiss) var dismiss
    
    @StateObject var goalSetViewModel: GoalSetViewModel
//    @StateObject var viewModel: ViewModel
    
    @State var showingNutrientsPicker: Bool = false
    @State var showingEmojiPicker = false
    
    @State var showingEquivalentValuesToggle: Bool
    @State var showingEquivalentValues = false

    @FocusState var isFocused: Bool
    
    //TODO: Use user's units here
    public init(
        isMealProfile: Bool,
        existingGoalSet: GoalSet? = nil,
        bodyProfile: BodyProfile? = nil,
        presentedGoalId: UUID? = nil
    ) {
        let goalSetViewModel = GoalSetViewModel(
            userUnits: .standard,
            isMealProfile: isMealProfile,
            existingGoalSet: existingGoalSet,
            bodyProfile: bodyProfile,
            presentedGoalId: presentedGoalId
        )
        _goalSetViewModel = StateObject(wrappedValue: goalSetViewModel)
        
        _showingEquivalentValuesToggle = State(initialValue: goalSetViewModel.containsGoalWithEquivalentValues)
        
//        let viewModel = ViewModel(
//            userUnits: .standard,
//            bodyProfile: bodyProfile,
//            presentedGoalId: presentedGoalId,
//            existingGoalSet: existingGoalSet
//        )
//        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack(path: $goalSetViewModel.path) {
            content
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar { trailingContent }
            .toolbar { leadingContent }
            .sheet(isPresented: $showingNutrientsPicker) { nutrientsPicker }
            .sheet(isPresented: $showingEmojiPicker) { emojiPicker }
            .navigationDestination(for: GoalSetFormRoute.self, destination: navigationDestination)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: goalSetViewModel.containsGoalWithEquivalentValues, perform: containsGoalWithEquivalentValuesChanged)
        }
    }
    
    func containsGoalWithEquivalentValuesChanged(to newValue: Bool) {
        withAnimation {
            showingEquivalentValuesToggle = newValue
        }
    }
    
    @ViewBuilder
    func navigationDestination(for route: GoalSetFormRoute) -> some View {
        switch route {
        case .goal(let goalViewModel):
            goalForm(for: goalViewModel)
        }
    }
    
    var title: String {
        let typeName = goalSetViewModel.isMealProfile ? "Meal Type": "Diet"
        return goalSetViewModel.existingGoalSet == nil ? "New \(typeName)" : typeName
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
        if let energy = goalSetViewModel.energyGoal {
            cell(for: energy)
        } else if let autoEnergy = goalSetViewModel.autoEnergyGoalViewModel {
            cell(for: autoEnergy, isButton: false)
        }
    }
    
    func cell(for goalViewModel: GoalViewModel, isButton: Bool = true) -> some View {
        var label: some View {
            GoalCell(
                goal: goalViewModel,
                showingEquivalentValues: $showingEquivalentValues
            )
        }
        return Group {
            if isButton {
                Button {
                    isFocused = false
                    goalSetViewModel.path.append(.goal(goalViewModel))
                } label: {
                    label
                }
            } else {
                label
            }
        }
    }
        
    @ViewBuilder
    var macroCells: some View {
        if !goalSetViewModel.macroGoals.isEmpty {
            Group {
                subtitleCell("Macros")
                ForEach(goalSetViewModel.macroGoals, id: \.self) {
                    cell(for: $0)
                }
            }
        }
    }
    
    @ViewBuilder
    var microCells: some View {
        if !goalSetViewModel.microGoals.isEmpty {
            Group {
                subtitleCell("Micronutrients")
                ForEach(goalSetViewModel.microGoals, id: \.self) {
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
        if goalSetViewModel.containsDynamicGoal {
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
            Haptics.feedback(style: .soft)
            showingEmojiPicker = true
        } label: {
            Text(goalSetViewModel.emoji)
                .font(.system(size: 50))
        }
    }
    
    @ViewBuilder
    var nameTextField: some View {
        TextField("Enter a Name", text: $goalSetViewModel.name)
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
