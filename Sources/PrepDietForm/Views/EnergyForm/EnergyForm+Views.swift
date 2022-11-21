import SwiftUI
import SwiftUISugar
import SwiftHaptics

extension EnergyForm {
    
    var lowerBoundSection: some View {
        let binding = Binding<Double?>(
            get: {
                return goal.lowerBound
            },
            set: { newValue in
                withAnimation {
                    goal.lowerBound = newValue
                }
            }
        )
        
        var header: some View {
            Text(goal.haveBothBounds ? "From" : "At least")
        }
        return FormStyledSection(header: header) {
            HStack {
                DoubleTextField(
                    double: binding,
                    placeholder: "Optional",
                    shouldResignFocus: $shouldResignFocus
                )
            }
        }
    }
    
    var upperBoundSection: some View {
        let binding = Binding<Double?>(
            get: { goal.upperBound },
            set: { newValue in
                withAnimation {
                    goal.upperBound = newValue
                }
            }
        )

        var header: some View {
            Text(goal.haveBothBounds ? "To" : "At most")
        }
        return FormStyledSection(header: header) {
            HStack {
                DoubleTextField(
                    double: binding,
                    placeholder: "Optional",
                    shouldResignFocus: $shouldResignFocus
                )
            }
        }
    }
    
    var middleSection: some View {
        VStack(spacing: 7) {
            Text("")
            if goal.lowerBound != nil, goal.upperBound == nil {
                Button {
                    Haptics.feedback(style: .rigid)
                    goal.upperBound = goal.lowerBound
                    goal.lowerBound = nil
                } label: {
//                    Image(systemName: "arrowshape.right.fill")
                    Image(systemName: "rectangle.righthalf.inset.filled.arrow.right")
                        .foregroundColor(.accentColor)
                }
            } else if goal.upperBound != nil, goal.lowerBound == nil {
                Button {
                    Haptics.feedback(style: .rigid)
                    goal.lowerBound = goal.upperBound
                    goal.upperBound = nil
                } label: {
//                    Image(systemName: "arrowshape.left.fill")
                    Image(systemName: "rectangle.lefthalf.inset.filled.arrow.left")
                        .foregroundColor(.accentColor)
                }
            }
//            else if goal.upperBound != nil, goal.lowerBound != nil {
//                Text("to")
//                    .font(.system(size: 17))
//                    .foregroundColor(Color(.tertiaryLabel))
//            }
        }
        .padding(.top, 10)
        .frame(width: 16, height: 20)
    }
    
    var unitView: some View {
        HStack {
            Text(goal.energyGoalType?.description ?? "")
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
                Text("Currently Equals")
            } else {
                Text("Equals")
            }
        }
        
        return Group {
            if goal.haveEquivalentValues {
                FormStyledSection(header: header) {
                    goal.equivalentTextHStack
                }
            }
        }
    }
}

extension EnergyForm {
    var body: some View {
        FormStyledScrollView {
            HStack(spacing: 0) {
                lowerBoundSection
                middleSection
                upperBoundSection
            }
            unitSection
                .padding(.bottom, 10)
            equivalentSection
        }
        .navigationTitle("Energy")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { trailingContent }
        .toolbar { bottomContents }
        .toolbar { keyboardContents }
        .onChange(of: pickedMealEnergyGoalType, perform: mealEnergyGoalChanged)
        .onChange(of: pickedDietEnergyGoalType, perform: dietEnergyGoalChanged)
        .onChange(of: pickedDelta, perform: deltaChanged)
        .onAppear(perform: appeared)
        .sheet(isPresented: $showingTDEEForm) { tdeeForm }
        .onDisappear(perform: goal.validateEnergy)
        .scrollDismissesKeyboard(.interactively)
    }
    
    var bottomContents: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            deleteButton
            Spacer()
        }
    }

    var keyboardContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            deleteButton
            Spacer()
            doneButton
        }
    }

    var trailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            dynamicIndicator
//            deleteButton
        }
    }
    
    var doneButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "checkmark")
        }
    }
    
    @ViewBuilder
    var dynamicIndicator: some View {
        if isDynamic {
            appleHealthBolt
            Text("Dynamic")
                .font(.footnote)
                .textCase(.uppercase)
                .foregroundColor(Color(.tertiaryLabel))
        }
    }
    
    var deleteButton: some View {
        Button(role: .destructive) {
            didTapDelete(goal)
        } label: {
            Image(systemName: "trash")
//            Image(systemName: "minus.circle")
//            Text("Delete")
//            Text("Remove Goal")
                .foregroundColor(.red)
        }
    }
    
    var isDynamic: Bool {
        goal.isDynamic
    }
    
    @ViewBuilder
    var unitsFooter: some View {
        if isDynamic {
//            Text("Your maintenance energy will automatically adjust to changes from the Health App, making this a dynamic goal.")
            Text("Your maintenance energy is synced with the Health App, enabling this goal to automatically adjust to any changes.")
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
                    .padding(.horizontal, 17)
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
        TDEEForm(existingProfile: viewModel.bodyProfile, userUnits: .standard) { profile in
            viewModel.setBodyProfile(profile)            
        }
    }
    
    @ViewBuilder
    var tdeeButton: some View {
        if shouldShowEnergyDeltaElements {
            Button {
                shouldResignFocus.toggle()
                showingTDEEForm = true
            } label: {
                if let profile = viewModel.bodyProfile, let formattedTDEE = profile.formattedTDEEWithUnit {
                    if profile.parameters.hasDynamicTDEE {
                        PickerLabel(
                            formattedTDEE,
                            systemImage: "flame.fill",
                            imageColor: Color(hex: "F3DED7"),
                            backgroundGradientTop: Color(hex: AppleHealthTopColorHex),
                            backgroundGradientBottom: Color(hex: AppleHealthBottomColorHex),
                            foregroundColor: .white,
                            imageScale: .small
                        )
                    } else {
                        PickerLabel(
                            formattedTDEE,
                            systemImage: "flame.fill",
                            imageColor: Color(.tertiaryLabel),
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

import PrepDataTypes

extension GoalViewModel {
    
    var equivalentUnitString: String? {
        switch type {
        case .energy(let type):
            switch type {
            default:
                return goalSet.userUnits.energy.shortDescription
            }
        case .macro(let type, _):
            switch type {
            case .gramsPerWorkoutDuration:
                return type.description
            default:
                return NutrientUnit.g.shortDescription
            }
        case .micro(let type, _, let nutrientUnit, _):
            switch type {
            case .fixed:
                return type.description(nutrientUnit: nutrientUnit)
            case .quantityPerWorkoutDuration(_):
                return type.description(nutrientUnit: nutrientUnit)
            }
        }
    }
    
    var equivalentLowerBound: Double? {
        switch type {
        case .energy(let energyGoalType):
            switch energyGoalType {
                
            case .fromMaintenance(let energyUnit, let delta):
                guard let tdee = goalSet.bodyProfile?.tdee(in: energyUnit) else { return nil }
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
                
            case .percentFromMaintenance(let delta):
                guard let tdee = goalSet.bodyProfile?.tdeeInUnit else { return nil }
                switch delta {
                case .deficit:
                    if let upperBound, let lowerBound {
                        if upperBound > lowerBound {
                            return tdee - ((upperBound/100) * tdee)
                        } else {
                            return tdee - ((lowerBound/100) * tdee)
                        }
                    } else {
                        guard let lowerBound else { return nil }
                        return tdee - ((lowerBound/100) * tdee)
                    }
                case .surplus:
                    guard let lowerBound else { return nil }
                    return tdee + ((lowerBound/100) * tdee)
                }
                
            case .fixed:
                return lowerBound
            }
        
        case .macro(let macroGoalType, let macro):
            if let trueLowerBound {
                return macroValue(
                    from: trueLowerBound,
                    for: macroGoalType,
                    macro: macro,
                    energy: goalSet.energyGoal?.equivalentLowerBound ?? goalSet.energyGoal?.equivalentUpperBound
                )
            }
//            else if
//                macroGoalType == .percentageOfEnergy,
//                let trueUpperBound,
//                goalSet.energyGoal?.haveBothBounds == true,
//                let lowerEnergy = goalSet.energyGoal?.equivalentLowerBound
//            {
//                return macroValue(
//                    from: trueUpperBound,
//                    for: macroGoalType,
//                    macro: macro,
//                    energy: lowerEnergy
//                )
//            }
            else {
                return nil
            }
            
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
                guard let tdee = goalSet.bodyProfile?.tdee(in: energyUnit) else { return nil }
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
                guard let tdee = goalSet.bodyProfile?.tdeeInUnit else { return nil }
                switch delta {
                case .deficit:
                    if let upperBound, let lowerBound {
                        if upperBound < lowerBound {
                            return tdee - ((upperBound/100) * tdee)
                        } else {
                            return tdee - ((lowerBound/100) * tdee)
                        }
                    } else {
                        guard let upperBound else { return nil }
                        return tdee - ((upperBound/100) * tdee)
                    }
                case .surplus:
                    guard let upperBound else { return nil }
                    return tdee + ((upperBound/100) * tdee)
                }

            case .fixed:
                return upperBound
            }
            
        case .macro(let macroGoalType, let macro):
            if let trueUpperBound {
                return macroValue(
                    from: trueUpperBound,
                    for: macroGoalType,
                    macro: macro,
                    energy: goalSet.energyGoal?.equivalentUpperBound ?? goalSet.energyGoal?.equivalentLowerBound
                )
            }
//            else if
//                macroGoalType == .percentageOfEnergy,
//                let trueLowerBound,
//                goalSet.energyGoal?.haveBothBounds == true,
//                let upperEnergy = goalSet.energyGoal?.equivalentUpperBound
//            {
//                return macroValue(
//                    from: trueLowerBound,
//                    for: macroGoalType,
//                    macro: macro,
//                    energy: upperEnergy
//                )
//            }
            else {
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
    
    var trueLowerBound: Double? {
        guard let lowerBound else { return nil }
        guard let upperBound else { return lowerBound }
        if upperBound == lowerBound {
            return nil
        }
        if upperBound < lowerBound {
            return upperBound
        }
        return lowerBound
    }
    
    var trueUpperBound: Double? {
        guard let upperBound else { return nil }
        guard let lowerBound else { return upperBound }
        if upperBound == lowerBound {
            return upperBound
        }
        if lowerBound > upperBound {
            return lowerBound
        }
        return upperBound
    }
    
    func macroValue(from value: Double, for macroGoalType: MacroGoalType, macro: Macro, energy: Double?) -> Double? {
        switch macroGoalType {
        case .fixed:
            return nil
        case .gramsPerBodyMass(let bodyMass, let weightUnit):
            switch bodyMass {
            case .weight:
                guard let weight = goalSet.bodyProfile?.weight(in: weightUnit)
                else { return nil }
                return value * weight
                
            case .leanMass:
                guard let lbm = goalSet.bodyProfile?.lbm(in: weightUnit)
                else { return nil}
                return value * lbm
                
            }
            
        case .percentageOfEnergy:
            guard let energy else { return nil }
            let energyUnit = goalSet.bodyProfile?.parameters.energyUnit ?? self.goalSet.userUnits.energy
            
            let energyInKcal = energyUnit == .kcal ? energy : energy * KcalsPerKilojule
            return macro.grams(equallingPercent: value, of: energyInKcal)
            
        case .gramsPerWorkoutDuration(let minutes):
            return nil
        }
    }
}

extension Macro {
    
    func grams(equallingPercent percent: Double, of energy: Double) -> Double {
        guard percent >= 0, percent <= 100, energy > 0 else { return 0 }
        let energyPortion = energy * (percent / 100)
        return energyPortion / kcalsPerGram
    }
    
    var kcalsPerGram: Double {
        switch self {
        case .carb:
            return KcalsPerGramOfCarb
        case .fat:
            return KcalsPerGramOfFat
        case .protein:
            return KcalsPerGramOfProtein
        }
    }
}

//MARK: - 👁‍🗨 Previews

struct DietForm_Previews: PreviewProvider {
    static var previews: some View {
        DietPreview()
    }
}

struct MealTypeForm_Previews: PreviewProvider {
    static var previews: some View {
        MealTypePreview()
    }
}


struct EnergyForm_Previews: PreviewProvider {
    
    static var previews: some View {
        EnergyFormPreview()
    }
}

struct MacroForm_Previews: PreviewProvider {
    
    static var previews: some View {
        MacroFormPreview()
    }
}


//MARK: Energy Form Preview

struct EnergyFormPreview: View {
    
    @StateObject var viewModel: GoalSetForm.ViewModel
    @StateObject var goalViewModel: GoalViewModel
    
    init() {
        let goalSetViewModel = GoalSetForm.ViewModel(
            userUnits:.standard,
            isMealProfile: false,
            existingGoalSet: nil,
            bodyProfile: BodyProfile(
                id: UUID(),
                parameters: .init(energyUnit: .kcal, weightUnit: .kg, heightUnit: .cm, restingEnergy: 2000, restingEnergySource: .userEntered, activeEnergy: 1100, activeEnergySource: .userEntered),
                syncStatus: .notSynced,
                updatedAt: Date().timeIntervalSince1970
            )
        )
        let goalViewModel = GoalViewModel(
            goalSet: goalSetViewModel,
            isForMeal: false,
            type: .energy(.fromMaintenance(.kcal, .deficit)),
            lowerBound: 500
//            , upperBound: 750
        )
        _viewModel = StateObject(wrappedValue: goalSetViewModel)
        _goalViewModel = StateObject(wrappedValue: goalViewModel)
    }
    
    var body: some View {
        NavigationView {
            EnergyForm(goal: goalViewModel, didTapDelete: { _ in
                
            })
                .environmentObject(viewModel)
        }
    }
}

//MARK: Macro Form

struct MacroFormPreview: View {
    
    @StateObject var goalSet: GoalSetForm.ViewModel
    @StateObject var goal: GoalViewModel
    
    init() {
        let goalSet = GoalSetForm.ViewModel(
            userUnits: .standard,
            isMealProfile: false,
            existingGoalSet: GoalSet(
                name: "Bulking",
                emoji: "",
                goals: [
                    Goal(type: .energy(.fromMaintenance(.kcal, .surplus)), lowerBound: 500, upperBound: 1500)
                ]
            ),
            bodyProfile: .mock(
                restingEnergy: 1000,
                lbm: 77
            )
        )
        let goal = GoalViewModel(
            goalSet: goalSet,
            isForMeal: false,
            type: .macro(.percentageOfEnergy, .carb),
            lowerBound: 20,
            upperBound: 30
        )
        _goalSet = StateObject(wrappedValue: goalSet)
        _goal = StateObject(wrappedValue: goal)
    }
    
    var body: some View {
        NavigationView {
            MacroForm(goal: goal, didTapDelete: { _ in
                
            })
                .environmentObject(goalSet)
        }
    }
}

//MARK: - GoalSet Form Preview
public struct DietPreview: View {
    
    static let energyGoal = Goal(
        type: .energy(.fromMaintenance(.kcal, .surplus)),
        lowerBound: 500,
        upperBound: 750
    )
    
    static let fatGoalPerBodyMass = Goal(
        type: .macro(.gramsPerBodyMass(.leanMass, .kg), .fat),
        upperBound: 1
    )

    static let fatGoalPerEnergy = Goal(
        type: .macro(.percentageOfEnergy, .fat),
        upperBound: 20
    )

    static let proteinGoal = Goal(
        type: .macro(.gramsPerBodyMass(.weight, .kg), .protein),
        lowerBound: 1.1,
        upperBound: 2.5
    )

    static let goalSet = GoalSet(
        name: "Cutting",
        emoji: "🫃🏽",
        goals: [
            energyGoal,
            proteinGoal,
            fatGoalPerEnergy,
        ],
        isMealProfile: false
    )
    
    public init() { }
    
    public var body: some View {
        GoalSetForm(
            isMealProfile: false,
            existingGoalSet: Self.goalSet,
            bodyProfile: BodyProfile.mockBodyProfile
//            , presentedGoalId: Self.fatGoal.id
        )
    }
}

public struct MealTypePreview: View {
    
    static let energyGoal = Goal(
        type: .energy(.fixed(.kcal)),
        lowerBound: 250,
        upperBound: 350
    )
    
    static let proteinGoal = Goal(
        type: .macro(.fixed, .protein),
        lowerBound: 20
    )

    static let carbGoal = Goal(
        type: .macro(.gramsPerWorkoutDuration(.min), .carb),
        lowerBound: 0.5
    )

    static let goalSet = GoalSet(
        name: "Pre-workout",
        emoji: "🏋🏽‍♂️",
        goals: [
            energyGoal,
            proteinGoal,
            carbGoal,
        ],
        isMealProfile: true
    )
    
    public init() { }
    
    public var body: some View {
        GoalSetForm(
            isMealProfile: true,
            existingGoalSet: Self.goalSet,
            bodyProfile: BodyProfile.mockBodyProfile
//            , presentedGoalId: Self.fatGoal.id
        )
    }
}

extension BodyProfile {
    static let mockBodyProfile = BodyProfile.mock(
        restingEnergy: 2000,
        activeEnergy: 1000,
        weight: 98,
        lbm: 65
    )
}
