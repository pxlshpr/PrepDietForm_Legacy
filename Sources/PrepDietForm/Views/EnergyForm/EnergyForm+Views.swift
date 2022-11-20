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
                DoubleTextField(double: binding, placeholder: "Optional")
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
                DoubleTextField(double: binding, placeholder: "Optional")
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
                    HStack {
                        goal.equivalentTextHStack
                        Spacer()
                    }
//                    HStack {
//                        if let lower = goal.equivalentLowerBound {
//                            if goal.equivalentUpperBound == nil {
//                                equivalentAccessoryText("at least")
//                            }
//                            HStack(spacing: 3) {
//                                equivalentValueText(lower.formattedEnergy)
//                                if goal.equivalentUpperBound == nil {
//                                    equivalentUnitText("kcal")
//                                }
//                            }
//                        }
//                        if let upper = goal.equivalentUpperBound {
//                            equivalentAccessoryText(goal.lowerBound == nil ? "up to" : "to")
//                            HStack(spacing: 3) {
//                                equivalentValueText(upper.formattedEnergy)
//                                equivalentUnitText("kcal")
//                            }
//                        }
//                        Spacer()
//                    }
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
        .onChange(of: pickedMealEnergyGoalType, perform: mealEnergyGoalChanged)
        .onChange(of: pickedDietEnergyGoalType, perform: dietEnergyGoalChanged)
        .onChange(of: pickedDelta, perform: deltaChanged)
        .onAppear(perform: appeared)
        .sheet(isPresented: $showingTDEEForm) { tdeeForm }
        .onDisappear(perform: goal.validateEnergy)
        .onChange(of: goal.lowerBound, perform: lowerBoundChanged)
        .onChange(of: goal.upperBound, perform: upperBoundChanged)
    }
    
    func lowerBoundChanged(to newValue: Double?) {
        print("lowerBound is now: \(newValue)")
    }
    
    func upperBoundChanged(to newValue: Double?) {
        print("upperBound is now: \(newValue)")
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
        viewModel.bodyProfile?.parameters.updatesWithHealthApp == true
    }
    
    @ViewBuilder
    var unitsFooter: some View {
        if isDynamic {
//            Text("Your maintenance energy will automatically adjust to changes from the Health App, making this a dynamic goal.")
            Text("Your maintenance energy is synced with the Health App, making this goal automatically adjust to any changes.")
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
                showingTDEEForm = true
            } label: {
                if let profile = viewModel.bodyProfile, let formattedTDEE = profile.formattedTDEEWithUnit {
                    if profile.parameters.updatesWithHealthApp {
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
        case .macro:
            return NutrientUnit.g.shortDescription
        case .micro(_, _, let nutrientUnit, _):
            return nutrientUnit.shortDescription
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
            } else if
                macroGoalType == .percentageOfEnergy,
                let trueUpperBound,
                goalSet.energyGoal?.haveBothBounds == true,
                let lowerEnergy = goalSet.energyGoal?.equivalentLowerBound
            {
                return macroValue(
                    from: trueUpperBound,
                    for: macroGoalType,
                    macro: macro,
                    energy: lowerEnergy
                )
            } else {
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
            } else if
                macroGoalType == .percentageOfEnergy,
                let trueLowerBound,
                goalSet.energyGoal?.haveBothBounds == true,
                let upperEnergy = goalSet.energyGoal?.equivalentUpperBound
            {
                return macroValue(
                    from: trueLowerBound,
                    for: macroGoalType,
                    macro: macro,
                    energy: upperEnergy
                )
            } else {
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
