import SwiftUI
import SwiftUISugar

extension EnergyForm {
    
    var lowerBoundSection: some View {
        let binding = Binding<Double?>(
            get: {
                return goal.lowerBound
            },
            set: {
                goal.lowerBound = $0
            }
        )
        return FormStyledSection(header: Text("At least")) {
            HStack {
                DoubleTextField(double: binding, placeholder: "Optional")
            }
        }
    }
    
    var upperBoundSection: some View {
        let binding = Binding<Double?>(
            get: { goal.upperBound },
            set: { goal.upperBound = $0 }
        )
        return FormStyledSection(header: Text("At most")) {
            HStack {
                DoubleTextField(double: binding, placeholder: "Optional")
            }
        }
    }
    
    var unitView: some View {
        HStack {
            Text(goal.energyGoalType?.shortDescription ?? "")
                .foregroundColor(Color(.tertiaryLabel))
            if let difference = goal.energyGoalDelta {
                Spacer()
                Text(difference.description)
                    .foregroundColor(Color(.quaternaryLabel))
            }
        }
    }
    
    @ViewBuilder
    var footer: some View {
        EmptyView()
    }
    
    var equivalentSection: some View {
        @ViewBuilder
        var header: some View {
            if isDynamic {
                Text("Currently")
            }
        }
        
        return Group {
            if goal.haveEquivalentValues {
                FormStyledSection(header: header) {
                    HStack {
                        if let lower = goal.equivalentLowerBound {
                            if goal.equivalentUpperBound == nil {
                                equivalentAccessoryText("at least")
                            }
                            HStack(spacing: 3) {
                                equivalentValueText(lower.formattedEnergy)
                                if goal.equivalentUpperBound == nil {
                                    equivalentUnitText("kcal")
                                }
                            }
                        }
                        if let upper = goal.equivalentUpperBound {
                            equivalentAccessoryText(goal.lowerBound == nil ? "up to" : "to")
                            HStack(spacing: 3) {
                                equivalentValueText(upper.formattedEnergy)
                                equivalentUnitText("kcal")
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

func equivalentAccessoryText(_ string: String) -> some View {
    Text(string)
        .font(.system(.callout, design: .rounded, weight: .regular))
        .foregroundColor(Color(.tertiaryLabel))
}

func equivalentUnitText(_ string: String) -> some View {
    Text(string)
        .font(.system(.caption2, design: .rounded, weight: .regular))
        .foregroundColor(Color(.tertiaryLabel))
}

func equivalentValueText(_ string: String) -> some View {
    Text(string)
        .monospacedDigit()
        .font(.system(.body, design: .rounded, weight: .regular))
        .foregroundColor(.secondary)
}

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
        .toolbar { trailingContent }
        .onChange(of: pickedMealEnergyGoalType, perform: mealEnergyGoalChanged)
        .onChange(of: pickedDietEnergyGoalType, perform: dietEnergyGoalChanged)
        .onChange(of: pickedDelta, perform: deltaChanged)
        .onAppear(perform: appeared)
        .sheet(isPresented: $showingTDEEForm) { tdeeForm }
    }
    
    var trailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if isDynamic {
                Text("Dynamic")
                    .font(.footnote)
                    .textCase(.uppercase)
                    .foregroundColor(Color(.tertiaryLabel))
                Image(systemName: "bolt.horizontal.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                Color(hex: AppleHealthTopColorHex),
                                Color(hex: AppleHealthBottomColorHex)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
    }
    
    var isDynamic: Bool {
        viewModel.currentTDEEProfile?.parameters.updatesWithHealthApp == true
    }
    
    @ViewBuilder
    var unitsFooter: some View {
        if isDynamic {
            Text("Your maintenance energy will automatically adjust to changes from the Health App, making this a dynamic goal.")
        }
    }
    
    var unitSection: some View {
        var horizontalScrollView: some View {
            FormStyledSection(footer: unitsFooter, horizontalPadding: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        typePicker
                        deltaPicker
                        tdeeButton
                    }
                    .padding(.horizontal, 12)
                }
                .frame(maxWidth: .infinity)
            }
        }
        
        var flowView: some View {
            FormStyledSection {
                FlowView(alignment: .leading, spacing: 10, padding: 37) {
                    typePicker
                    deltaPicker
                    tdeeButton
                }
            }
        }
        
        return Group {
            horizontalScrollView
//            flowView
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
                    if profile.parameters.updatesWithHealthApp {
                        PickerLabel(
                            profile.formattedTDEEWithUnit,
                            systemImage: "flame.fill",
                            imageColor: Color(hex: "F3DED7"),
                            backgroundGradientTop: Color(hex: AppleHealthTopColorHex),
                            backgroundGradientBottom: Color(hex: AppleHealthBottomColorHex),
                            foregroundColor: .white,
                            imageScale: .small
                        )
                    } else {
                        PickerLabel(
                            profile.formattedTDEEWithUnit,
                            systemImage: "flame.fill",
                            imageColor: Color(.secondaryLabel),
                            imageScale: .small
                        )
                    }
                } else {
                    PickerLabel(
                        "set",
//                        prefix: "set",
                        systemImage: "flame.fill",
                        imageColor: Color.white.opacity(0.75),
                        backgroundColor: .accentColor,
                        foregroundColor: .white,
                        prefixColor: Color.white.opacity(0.75),
                        imageScale: .small
                    )
                }
            }
        }
    }
}

extension GoalViewModel {
    var equivalentLowerBound: Double? {
        switch type {
        case .energy(let energyGoalType):
            switch energyGoalType {
                
            case .fromMaintenance(let energyUnit, let delta):
                guard let tdee = goalSet.currentTDEEProfile?.tdee(in: energyUnit) else { return nil }
                switch delta {
                case .deficit:
                    if let upperBound, let lowerBound {
                        if upperBound > lowerBound {
                            return tdee - upperBound
                        } else {
                            return tdee - lowerBound
                        }
                    } else {
                        guard let lowerBound else { return nil }
                        return tdee - lowerBound
                    }
                case .surplus:
                    guard let lowerBound else { return nil }
                    return tdee + lowerBound
                }
                
                //TODO: Handle this
            case .percentFromMaintenance(let delta):
                return nil
            case .percentOfDietGoal:
                //TODO: Handle this
                return nil
            case .fixed:
                return nil
            }
//        case .macro(let macroGoalType, let macro):
//            return nil
//        case .micro(let microGoalType, let nutrientType, let nutrientUnit):
//            return nil
        default:
            return nil
        }
    }
    
    var equivalentUpperBound: Double? {
        switch type {
        case .energy(let energyGoalType):
            switch energyGoalType {
                
            case .fromMaintenance(let energyUnit, let delta):
                guard let tdee = goalSet.currentTDEEProfile?.tdee(in: energyUnit) else { return nil }
                switch delta {
                case .deficit:
                    if let upperBound, let lowerBound {
                        if upperBound < lowerBound {
                            return tdee - upperBound
                        } else {
                            return tdee - lowerBound
                        }
                    } else {
                        guard let upperBound else { return nil }
                        return tdee - upperBound
                    }
                case .surplus:
                    guard let upperBound else { return nil }
                    return tdee + upperBound
                }
                
                //TODO: Handle this
            case .percentFromMaintenance(let delta):
                return nil
            case .percentOfDietGoal:
                //TODO: Handle this
                return nil
            case .fixed:
                return nil
            }
//        case .macro(let macroGoalType, let macro):
//            return nil
//        case .micro(let microGoalType, let nutrientType, let nutrientUnit):
//            return nil
        default:
            return nil
        }
    }
}

struct EnergyFormPreview: View {
    
    @StateObject var viewModel: GoalSetForm.ViewModel
    @StateObject var goalViewModel: GoalViewModel
    
    init() {
        let goalSet = GoalSetForm.ViewModel(
            isMealProfile: false, existingGoalSet: nil,
            currentTDEEProfile: TDEEProfile(
                id: UUID(),
                tdeeInKcal: 3100,
                parameters: .init(energyUnit: .kcal, weightUnit: .kg, heightUnit: .cm, restingEnergy: 2000, restingEnergySource: .userEntered, activeEnergy: 1100, activeEnergySource: .userEntered),
                syncStatus: .notSynced,
                updatedAt: Date().timeIntervalSince1970
            )
        )
        let goal = GoalViewModel(
            goalSet: goalSet,
            type: .energy(.fromMaintenance(.kcal, .deficit)),
            lowerBound: 500
            , upperBound: 750
        )
        _viewModel = StateObject(wrappedValue: goalSet)
        _goalViewModel = StateObject(wrappedValue: goal)
    }
    
    var body: some View {
        NavigationView {
            EnergyForm(goal: goalViewModel)
                .environmentObject(viewModel)
        }
    }
}

struct EnergyForm_Previews: PreviewProvider {
    
    static var previews: some View {
        EnergyFormPreview()
    }
}
