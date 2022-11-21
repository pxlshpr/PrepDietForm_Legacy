import SwiftUI
import PrepDataTypes
import Combine

public class GoalViewModel: ObservableObject {
    
    var goalSet: GoalSetForm.ViewModel
    
    let isForMeal: Bool
    
    let id: UUID
    @Published var type: GoalType
    @Published var lowerBound: Double?
    @Published var upperBound: Double?
    
    var anyCancellable: AnyCancellable? = nil
    
    public init(
        goalSet: GoalSetForm.ViewModel,
        isForMeal: Bool = false,
        id: UUID = UUID(),
        type: GoalType,
        lowerBound: Double? = nil,
        upperBound: Double? = nil
    ) {
        self.goalSet = goalSet
        self.isForMeal = isForMeal
        self.id = id
        self.type = type
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        
        anyCancellable = goalSet.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
    
    //MARK: - Energy
    var energyGoalType: EnergyGoalType? {
        get {
            switch type {
            case .energy(let type):
                return type
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .energy:
                self.type = .energy(newValue)
            default:
                break
            }
        }
    }
    
    var haveEquivalentValues: Bool {
        switch type {
        case .energy(let energyGoalType):
            switch energyGoalType {
            case .fixed:
                return false
            default:
                break
            }
        case .macro(let macroGoalType, _):
            switch macroGoalType {
            case .fixed:
                return false
            default:
                break
            }
        case .micro:
            return false
        }
        return equivalentLowerBound != nil || equivalentUpperBound != nil
    }
    
    var energyGoalDelta: EnergyGoalType.Delta? {
        get {
            switch type {
            case .energy(let type):
                return type.delta
            default:
                return nil
            }
        }
        set {
            switch type {
            case .energy(let type):
                //TODO: Set the type here
                var new = type
                new.delta = newValue
                self.type = .energy(new)
            default:
                break
            }
        }
    }
    
    //MARK: - Macro
    var macro: Macro? {
        switch type {
        case .macro(_, let macro):
            return macro
        default:
            return nil
        }
    }
    
    var macroGoalType: NutrientGoalType? {
        get {
            switch type {
            case .macro(let type, _):
                return type
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .macro(_, let macro):
                self.type = .macro(newValue, macro)
            default:
                break
            }
        }
    }
    
    var macroBodyMassType: NutrientGoalType.BodyMass? {
        get {
            switch type {
            case .macro(let type, _):
                return type.bodyMassType
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .macro(let macroGoalType, let macro):
                var new = macroGoalType
                new.bodyMassType = newValue
                self.type = .macro(new, macro)
            default:
                break
            }
        }
    }
    
    var macroBodyMassWeightUnit: WeightUnit? {
        get {
            switch type {
            case .macro(let type, _):
                return type.bodyMassWeightUnit
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .macro(let macroGoalType, let macro):
                var new = macroGoalType
                new.bodyMassWeightUnit = newValue
                self.type = .macro(new, macro)
            default:
                break
            }
        }
    }

    var bodyMassUnit: WeightUnit? {
        switch type {
        case .macro(let macroGoalType, _):
            switch macroGoalType {
            case .quantityPerBodyMass(_, let weightUnit):
                return weightUnit
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    var bodyMassType: NutrientGoalType.BodyMass? {
        switch type {
        case .macro(let macroGoalType, _):
            switch macroGoalType {
            case .quantityPerBodyMass(let bodyMassType, _):
                return bodyMassType
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    //MARK: - Micro
    var microGoalType: MicroGoalType? {
        get {
            switch type {
            case .micro(let type, _, _, _):
                return type
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .micro(_, let nutrientType, let nutrientUnit, let supportsMealSplitting):
                self.type = .micro(newValue, nutrientType, nutrientUnit, supportsMealSplitting)
            default:
                break
            }
        }
    }
    
    var microNutrientType: NutrientType? {
        switch type {
        case .micro(_, let nutrientType, _, _):
            return nutrientType
        default:
            return nil
        }
    }
    
    var microSupportsMealSplitting: Bool? {
        get {
            switch type {
            case .micro(_, _, _, let supportsMealSplitting):
                return supportsMealSplitting
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .micro(let microGoalType, let nutrientType, let nutrientUnit, _):
                self.type = .micro(microGoalType, nutrientType, nutrientUnit, newValue)
            default:
                break
            }
        }
    }
    
    var microNutrientUnit: NutrientUnit? {
        get {
            switch type {
            case .micro(_, _, let nutrientUnit, _):
                return nutrientUnit
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .micro(let microGoalType, let nutrientType, _, let supportsMealSplitting):
                self.type = .micro(microGoalType, nutrientType, newValue, supportsMealSplitting)
            default:
                break
            }
        }
    }

    //MARK: - Common
    
    var workoutDurationUnit: WorkoutDurationUnit? {
        switch type {
        case .macro(let type, _):
            switch type {
            case .quantityPerWorkoutDuration(let workoutDurationUnit):
                return workoutDurationUnit
            default:
                return nil
            }
        case .micro(let type, _, _, _):
            switch type {
            case .quantityPerWorkoutDuration(let workoutDurationUnit):
                return workoutDurationUnit
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    var isQuantityPerWorkoutDuration: Bool {
        workoutDurationUnit != nil
    }
    
    var energyUnit: EnergyUnit? {
        switch energyGoalType {
        case .fixed(let energyUnit):
            return energyUnit
        case .fromMaintenance(let energyUnit, _):
            return energyUnit
        default:
            return nil
        }
    }
    
    var haveBothBounds: Bool {
        lowerBound != nil && upperBound != nil
    }

    var hasOneBound: Bool {
        lowerBound != nil || upperBound != nil
    }

    var hasOneEquivalentBound: Bool {
        equivalentLowerBound != nil || equivalentUpperBound != nil
    }
    
    var isDynamic: Bool {
        switch type {
        case .energy:
            return energyIsSyncedWithHealth
        case .macro(let type, _):
            switch type {
            case .quantityPerBodyMass:
                return bodyMassIsSyncedWithHealth
            case .percentageOfEnergy:
                return energyGoalIsSyncedWithHealth
            default:
                return false
            }
        case .micro:
            //TODO: Do this
            return false
        }
    }
    
    var bodyMassIsSyncedWithHealth: Bool {
        guard let params = goalSet.bodyProfile?.parameters,
              let macroGoalType, macroGoalType.isGramsPerBodyMass,
              let bodyMassType
        else { return false }
        
        switch bodyMassType {
        case .weight:
            return params.weightUpdatesWithHealth == true
        case .leanMass:
            return params.lbmUpdatesWithHealth == true
        }
    }
    
    var energyGoalIsSyncedWithHealth: Bool {
        goalSet.energyGoal?.energyIsSyncedWithHealth ?? false
    }
    
    var energyIsSyncedWithHealth: Bool {
        guard let energyGoalType else { return false }
        switch energyGoalType {
        case .fromMaintenance, .percentFromMaintenance:
            return goalSet.bodyProfile?.hasDynamicTDEE ?? false
        default:
            return false
        }
    }
    
    var placeholderText: String? {
        /// First check that we have at least one value—otherwise returning the default placeholder
        guard hasOneBound else {
            return "Set Goal"
        }
        
        /// Now check for special cases (dependent goals, etc)
        switch type {
        case .energy(let type):
            switch type {
            case .fixed:
                break
            case .fromMaintenance, .percentFromMaintenance:
                guard goalSet.hasTDEE else {
                    return "Requires Maintenance Energy"
                }
            }
        case .macro(let type, _):
            switch type {
            case .fixed:
                break
            case .quantityPerBodyMass(let bodyMass, _):
                switch bodyMass {
                case .weight:
                    guard goalSet.hasWeight else {
                        return "Requires Weight"
                    }
                case .leanMass:
                    guard goalSet.hasLBM else {
                        return "Requires Lean Body Mass"
                    }
                }
            case .percentageOfEnergy:
                //TODO: Check that energyGoal is available
                guard let energyGoal = goalSet.energyGoal,
                      energyGoal.hasOneEquivalentBound
                else {
                    return "Requires Energy Goal"
                }
                return nil
            case .quantityPerWorkoutDuration:
                return "Calculated when used"
            }
        case .micro(let type, _, _, _):
            switch type {
            case .quantityPerWorkoutDuration:
                return "Calculated when used"
            case .fixed:
                break
            }
        }
        return nil
    }
}

extension GoalViewModel {
    func validateBoundsNotEqual() {
        guard let lowerBound, let upperBound else { return }
        if lowerBound == upperBound {
            withAnimation {
                self.lowerBound = nil
            }
        }
    }
    func validateLowerBoundLowerThanUpper() {
        guard let lowerBound, let upperBound else { return }
        if lowerBound > upperBound {
            withAnimation {
                self.lowerBound = upperBound
                self.upperBound = lowerBound
            }
        }
    }

    func validateNoBoundResultingInLessThan500(unit: EnergyUnit) {
        guard let profile = goalSet.bodyProfile,
              let tdee = profile.tdee(in: unit)?.rounded()
        else { return }
        
        if let lowerBound, tdee - lowerBound < 500 {
            withAnimation {
                self.lowerBound = tdee - 500
            }
        }

        if let upperBound, tdee - upperBound < 500 {
            withAnimation {
                self.upperBound = tdee - 500
            }
        }
    }
    
    func validateNoPercentageBoundResultingInLessThan500() {
        guard let profile = goalSet.bodyProfile,
              let tdee = profile.tdeeInUnit?.rounded()
        else { return }
        
        if let lowerBound, tdee - ((lowerBound/100) * tdee) < 500 {
            withAnimation {
                self.lowerBound = (tdee-500)/tdee * 100
            }
        }

        if let upperBound, tdee - ((upperBound/100) * tdee) < 500 {
            withAnimation {
                self.upperBound = (tdee-500)/tdee * 100
            }
        }
    }
    func validateNoPercentageBoundGreaterThan100() {
        if let lowerBound, lowerBound > 100 {
            withAnimation {
                self.lowerBound = 100
            }
        }
        if let upperBound, upperBound > 100 {
            withAnimation {
                self.upperBound = 100
            }
        }
    }

    func validateEnergy() {
        guard let energyGoalType else { return }
        switch energyGoalType {
        case .fixed:
            break
        case .fromMaintenance(let energyUnit, let delta):
            switch delta {
            case .surplus:
                break
            case .deficit:
                validateNoBoundResultingInLessThan500(unit: energyUnit)
            }
        case .percentFromMaintenance(let delta):
            switch delta {
            case .surplus:
                break
            case .deficit:
                validateNoPercentageBoundResultingInLessThan500()
            }
        }
        validateLowerBoundLowerThanUpper()
        validateBoundsNotEqual()
    }

    //TODO: Do this
    func validateMicro() {
        guard let microGoalType else { return }
        switch microGoalType {
        case .fixed:
            break
        case .quantityPerWorkoutDuration:
            break
        }
    }
    
    //TODO: Do this
    func validateMacro() {
        guard let macroGoalType else { return }
        switch macroGoalType {
        case .fixed:
            break
        case .quantityPerBodyMass:
            break
        case .quantityPerWorkoutDuration:
            break
        case .percentageOfEnergy:
            break
        }
//        switch macroGoalType {
//        case .fixed:
//            break
//        case .fromMaintenance(let energyUnit, let delta):
//            switch delta {
//            case .surplus:
//                break
//            case .deficit:
//                validateNoBoundResultingInLessThan500(unit: energyUnit)
//            }
//        case .percentFromMaintenance(let delta):
//            switch delta {
//            case .surplus:
//                break
//            case .deficit:
//                validateNoPercentageBoundResultingInLessThan500()
//            }
//        default:
//            return
//        }
        validateLowerBoundLowerThanUpper()
        validateBoundsNotEqual()
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
