import SwiftUI
import SwiftUISugar
import PrepDataTypes
import SwiftHaptics
import PrepViews


extension Array where Element == GoalViewModel {
    var containsEnergy: Bool {
        contains(where: { $0.type.isEnergy })
    }
    
    func containsMacro(_ macro: Macro) -> Bool {
        contains(where: { $0.type.macro == macro })
    }
    
    func containsMicro(_ nutrientType: NutrientType) -> Bool {
        contains(where: { $0.type.nutrientType == nutrientType })
    }
    
    func update(with goal: GoalViewModel) {
        guard let index = firstIndex(where: {
            if goal.type.isEnergy && $0.type.isEnergy { return true }
            if goal.type.macro == $0.type.macro { return true }
            if goal.type.nutrientType == $0.type.nutrientType { return true }
            return false
        }) else {
            return
        }
        self[index].lowerBound = goal.lowerBound
    }
}

extension DietForm {
    class ViewModel: ObservableObject {
        @Published var goals: [GoalViewModel] = []
    }
}

public class GoalViewModel: ObservableObject {
    @Published var id: UUID
    @Published var type: GoalType
    @Published var lowerBound: Double?
    @Published var upperBound: Double?
    
    public init(
        id: UUID = UUID(),
        type: GoalType,
        lowerBound: Double? = nil,
        upperBound: Double? = nil
    ) {
        self.id = id
        self.type = type
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }
    
    var energyGoalType: EnergyGoalType? {
        get {
            switch type {
            case .energy(let energyGoalUnit, _):
                return energyGoalUnit.energyGoalType
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .energy(_, let energyGoalDifference):
                self.type = .energy(
                    EnergyGoalUnit(energyGoalType: newValue),
                    energyGoalDifference
                )
            default:
                break
            }
        }
    }
    
    var energyGoalDifference: EnergyGoalDifference? {
        get {
            switch type {
            case .energy(_, let difference):
                return difference
            default:
                return nil
            }
        }
        set {
            switch type {
            case .energy(let unit, _):
                self.type = .energy(unit, newValue)
            default:
                break
            }
        }
    }
}

extension GoalViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type.identifyingHashValue)
    }
}

extension GoalViewModel: Equatable {
    public static func ==(lhs: GoalViewModel, rhs: GoalViewModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension DietForm.ViewModel {
    func containsMacro(_ macro: Macro) -> Bool {
        goals.containsMacro(macro)
    }
    
    func containsMicro(_ micro: NutrientType) -> Bool {
        goals.containsMicro(micro)
    }
    
    func didAddNutrients(pickedEnergy: Bool, pickedMacros: [Macro], pickedMicros: [NutrientType]) {
        if pickedEnergy, !goals.containsEnergy {
            goals.append(.init(type: .energy(.kcal, nil)))
        }
        for macro in pickedMacros {
            if !goals.containsMacro(macro) {
                goals.append(.init(type:.macro(.fixed, macro)))
            }
        }
        for nutrientType in pickedMicros {
            if !goals.containsMicro(nutrientType) {
                goals.append(.init(type: .micro(.fixed, nutrientType, nutrientType.units.first ?? .g)))
            }
        }
    }
    
    var energyGoal: GoalViewModel {
        get {
            guard let energyGoal = goals.first(where: { $0.type.isEnergy }) else {
                let newGoal = GoalViewModel(type: .energy(.kcal, nil))
                goals.append(newGoal)
                return newGoal
            }
            return energyGoal
        }
        set {
            self.goals.update(with: newValue)
        }
    }
}

public struct DietForm: View {
    
    @StateObject var viewModel = ViewModel()
    
    @State var name = "New Diet"
    
    @State var showingNutrientsPicker: Bool = false
    
    public init() {
        
    }
    
    public var body: some View {
        NavigationView {
            content
            .background(Color(.systemGroupedBackground))
            .navigationTitle($name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { trailingContent }
            .sheet(isPresented: $showingNutrientsPicker) { nutrientsPicker }
        }
    }
    
    func shouldShowMacro(_ macro: Macro) -> Bool {
        !viewModel.containsMacro(macro)
    }
    
    func hasUnusedMicros(in group: NutrientTypeGroup, matching searchString: String) -> Bool {
        group.nutrients.contains(where: {
            if searchString.isEmpty {
                return !hasMicronutrient($0)
            } else {
                return !hasMicronutrient($0) && $0.matchesSearchString(searchString)
            }
        })
    }
    
    func hasMicronutrient(_ nutrientType: NutrientType) -> Bool {
        viewModel.containsMicro(nutrientType)
    }
    

    
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
    var content: some View {
        if viewModel.goals.isEmpty {
            emptyContent
        } else {
            scrollView
        }
    }
    
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
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.goals, id: \.self) { goal in
                    NavigationLink {
                        goalForm(for: goal)
                    } label: {
                        GoalCell(goal: goal)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
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
    
    var trailingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if !viewModel.goals.isEmpty {
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
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
    
    func text(_ string: String) -> some View {
        Text(string)
            .font(.title3)
            .foregroundColor(Color(.tertiaryLabel))
    }
    
    var amountButton: some View {
        NavigationLink {
            
        } label: {
            label("1500 kcal", placeholder: "Required")
        }
    }
    
    var servingButton: some View {
        NavigationLink {
            
        } label: {
            label("2000 kcal", placeholder: "serving size")
        }
    }
    
    func label(_ string: String, placeholder: String) -> some View {
        Group {
            if string.isEmpty {
                HStack(spacing: 5) {
                    Text(placeholder)
                        .foregroundColor(Color(.quaternaryLabel))
                }
            } else {
                Text(string)
            }
        }
        .foregroundColor(.accentColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
}

//MARK: - Previews


struct DietForm_Previews: PreviewProvider {
    static var previews: some View {
        DietForm()
    }
}
