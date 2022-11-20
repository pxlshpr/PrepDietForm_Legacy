import SwiftUI
import PrepDataTypes

public class GoalViewModel: ObservableObject {
    
    var goalSet: GoalSetForm.ViewModel
    
    let isForMeal: Bool
    
    let id: UUID
    @Published var type: GoalType
    @Published var lowerBound: Double?
    @Published var upperBound: Double?
    
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
    
    var macroGoalType: MacroGoalType? {
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
    
    var macroBodyMassType: MacroGoalType.BodyMass? {
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
            case .gramsPerBodyMass(_, let weightUnit):
                return weightUnit
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    var bodyMassType: MacroGoalType.BodyMass? {
        switch type {
        case .macro(let macroGoalType, _):
            switch macroGoalType {
            case .gramsPerBodyMass(let bodyMassType, _):
                return bodyMassType
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    var workoutDurationUnit: WorkoutDurationUnit? {
        switch type {
        case .macro(let type, _):
            switch type {
            case .gramsPerWorkoutDuration(let workoutDurationUnit):
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
    
    func validateMacro() {
        guard let macroGoalType else { return }
        switch macroGoalType {
        case .fixed:
            break
        case .gramsPerBodyMass:
            break
        case .gramsPerWorkoutDuration:
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
