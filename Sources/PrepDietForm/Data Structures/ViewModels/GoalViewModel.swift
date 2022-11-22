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
            withAnimation {
                self?.objectWillChange.send()
            }
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
        case .macro(let type, _):
            switch type {
            case .fixed:
                return false
            default:
                break
            }
        case .micro(let type, _, _):
            switch type {
            case .fixed:
                return false
            default:
                break
            }
        }
        return equivalentLowerBound != nil || equivalentUpperBound != nil
    }
    
    var energyGoalDelta: EnergyGoalType.Delta? {
        switch type {
        case .energy(let type):
            return type.delta
        default:
            return nil
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
    
    var nutrientGoalType: NutrientGoalType? {
        get {
            switch type {
            case .macro(let type, _):
                return type
            case .micro(let type, _, _):
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
            case .micro(_, let nutrientType, let nutrientUnit):
                self.type = .micro(newValue, nutrientType, nutrientUnit)
            default:
                break
            }
        }
    }
    
//    var macroBodyMassType: NutrientGoalType.BodyMass? {
//        get {
//            switch type {
//            case .macro(let type, _):
//                return type.bodyMassType
//            default:
//                return nil
//            }
//        }
//        set {
//            guard let newValue else { return }
//            switch type {
//            case .macro(let macroGoalType, let macro):
//                var new = macroGoalType
//                new.bodyMassType = newValue
//                self.type = .macro(new, macro)
//            default:
//                break
//            }
//        }
//    }
    
//    var macroBodyMassWeightUnit: WeightUnit? {
//        get {
//            switch type {
//            case .macro(let type, _):
//                return type.bodyMassWeightUnit
//            default:
//                return nil
//            }
//        }
//        set {
//            guard let newValue else { return }
//            switch type {
//            case .macro(let macroGoalType, let macro):
//                var new = macroGoalType
//                new.bodyMassWeightUnit = newValue
//                self.type = .macro(new, macro)
//            default:
//                break
//            }
//        }
//    }

    var bodyMassUnit: WeightUnit? {
        guard let nutrientGoalType else { return nil }
        switch nutrientGoalType {
        case .quantityPerBodyMass(_, let weightUnit):
            return weightUnit
        default:
            return nil
        }
    }
    
    var bodyMassType: NutrientGoalType.BodyMass? {
        guard let nutrientGoalType else { return nil }
        switch nutrientGoalType {
        case .quantityPerBodyMass(let bodyMassType, _):
            return bodyMassType
        default:
            return nil
        }
    }
    
    //MARK: - Micro
//    var microGoalType: MicroGoalType? {
//        get {
//            switch type {
//            case .micro(let type, _, _, _):
//                return type
//            default:
//                return nil
//            }
//        }
//        set {
//            guard let newValue else { return }
//            switch type {
//            case .micro(_, let nutrientType, let nutrientUnit):
//                self.type = .micro(newValue, nutrientType, nutrientUnit)
//            default:
//                break
//            }
//        }
//    }
    
    var microNutrientType: NutrientType? {
        switch type {
        case .micro(_, let nutrientType, _):
            return nutrientType
        default:
            return nil
        }
    }
    
    var microNutrientUnit: NutrientUnit? {
        get {
            switch type {
            case .micro(_, _, let nutrientUnit):
                return nutrientUnit
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .micro(let microGoalType, let nutrientType, _):
                self.type = .micro(microGoalType, nutrientType, newValue)
            default:
                break
            }
        }
    }

    var nutrientUnit: NutrientUnit? {
        switch type {
        case .macro:
            return .g
        case .micro(_, let nutrientType, _):
            return nutrientType.units.first
        default:
            return nil
        }
    }
    
    //MARK: - Common
    var isEmpty: Bool {
        !hasOneBound
    }
    
    var workoutDurationUnit: WorkoutDurationUnit? {
        guard let nutrientGoalType else { return nil }
        switch nutrientGoalType {
        case .quantityPerWorkoutDuration(let workoutDurationUnit):
            return workoutDurationUnit
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
            return nutrientGoalTypeIsDynamic(type)
        case .micro(let type, _, _):
            return nutrientGoalTypeIsDynamic(type)
        }
    }
    
    func nutrientGoalTypeIsDynamic(_ nutrientGoalType: NutrientGoalType) -> Bool {
        switch nutrientGoalType {
        case .quantityPerBodyMass:
            return bodyMassIsSyncedWithHealth
        case .percentageOfEnergy:
            return energyGoalIsSyncedWithHealth
        default:
            return false
        }
    }
    
    var bodyMassIsSyncedWithHealth: Bool {
        guard let params = goalSet.bodyProfile?.parameters,
              let nutrientGoalType, nutrientGoalType.isQuantityPerBodyMass,
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
        case .macro, .micro:
            return nutrientPlaceholderText
        }
        return nil
    }
    
    var nutrientPlaceholderText: String? {
        guard let nutrientGoalType else { return nil }
        switch nutrientGoalType {
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
        case .percentageOfEnergy, .quantityPerEnergy:
            guard let energyGoal = goalSet.energyGoal,
                  energyGoal.hasOneEquivalentBound
            else {
                return "Requires Energy Goal"
            }
            return nil
        case .quantityPerWorkoutDuration:
            return "Calculated when used"
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
    func validateNutrient() {
        guard let nutrientGoalType else { return }
        switch nutrientGoalType {
        case .fixed:
            break
        case .quantityPerBodyMass:
            break
        case .quantityPerWorkoutDuration:
            break
        case .percentageOfEnergy:
            break
        case .quantityPerEnergy:
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
    
    var description: String {
        switch type {
        case .energy:
            return "Energy"
        case .macro:
            return macro?.description ?? "Macro"
        case .micro:
            return microNutrientType?.description ?? "Micro"
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


//MARK: - Equivalent Values

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
            case .quantityPerWorkoutDuration:
                return type.description(nutrientUnit: .g)
            default:
                return NutrientUnit.g.shortDescription
            }
        case .micro(let type, _, let nutrientUnit):
            switch type {
            case .quantityPerWorkoutDuration:
                return type.description(nutrientUnit: nutrientUnit)
            default:
                return nutrientUnit.shortDescription
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
        
        case .macro(let nutrientGoalType, let macro):
            guard let trueLowerBound else  {
                return nil
            }
            return macroValue(
                from: trueLowerBound,
                for: nutrientGoalType,
                macro: macro,
                energy: goalSet.energyGoal?.equivalentLowerBound ?? goalSet.energyGoal?.equivalentUpperBound
            )
            
        case .micro(let nutrientGoalType, let nutrientType, _):
            guard let trueLowerBound else  {
                return nil
            }
            return microValue(
                from: trueLowerBound,
                for: nutrientGoalType,
                nutrientType: nutrientType,
                energy: goalSet.energyGoal?.equivalentLowerBound ?? goalSet.energyGoal?.equivalentUpperBound
            )
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
            
        case .macro(let nutrientGoalType, let macro):
            guard let trueUpperBound else {
                return nil
            }
            return macroValue(
                from: trueUpperBound,
                for: nutrientGoalType,
                macro: macro,
                energy: goalSet.energyGoal?.equivalentUpperBound ?? goalSet.energyGoal?.equivalentLowerBound
            )
        case .micro(let nutrientGoalType, let nutrientType, _):
            guard let trueUpperBound else {
                return nil
            }
            return microValue(
                from: trueUpperBound,
                for: nutrientGoalType,
                nutrientType: nutrientType,
                energy: goalSet.energyGoal?.equivalentUpperBound ?? goalSet.energyGoal?.equivalentLowerBound
            )
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
    
    func calculatedQuantityPerEnergy(value: Double, perEnergyKcal: Double, from goalEnergyKcal: Double) -> Double? {
        guard perEnergyKcal > 0 else { return nil }
        return (value * goalEnergyKcal) / perEnergyKcal
    }
    
    func macroValue(from value: Double, for nutrientGoalType: NutrientGoalType, macro: Macro, energy: Double?) -> Double? {
        switch nutrientGoalType {
        case .quantityPerBodyMass(let bodyMass, let weightUnit):
            return calculatedQuantityForBodyMass(bodyMass, value: value, in: weightUnit)
            
        case .percentageOfEnergy:
            guard let energyInKcal = calculatedEnergyInKcal(from: energy) else { return nil }
            return macro.grams(equallingPercent: value, of: energyInKcal)
        
        case .quantityPerEnergy(let energyValue, let energyUnit):
            guard let goalEnergyKcal = calculatedEnergyInKcal(from: energy) else { return nil }
            let perEnergyKcal = energyUnit == .kcal ? energyValue : EnergyUnit.convertToKilocalories(fromKilojules: energyValue)
            return calculatedQuantityPerEnergy(value: value, perEnergyKcal: perEnergyKcal, from: goalEnergyKcal)
        default:
            return nil
        }
    }
    
    /// Returns this in grams
    func microValue(from value: Double, for nutrientGoalType: NutrientGoalType, nutrientType: NutrientType, energy: Double?) -> Double? {
        switch nutrientGoalType {
        case .quantityPerBodyMass(let bodyMass, let weightUnit):
            return calculatedQuantityForBodyMass(bodyMass, value: value, in: weightUnit)
            
        case .percentageOfEnergy:
            guard let energyInKcal = calculatedEnergyInKcal(from: energy) else { return nil }
            return nutrientType.grams(equallingPercent: value, of: energyInKcal)
        
        case .quantityPerEnergy(let energyValue, let energyUnit):
            guard let goalEnergyKcal = calculatedEnergyInKcal(from: energy) else { return nil }
            let perEnergyKcal = energyUnit == .kcal ? energyValue : EnergyUnit.convertToKilocalories(fromKilojules: energyValue)
            return calculatedQuantityPerEnergy(value: value, perEnergyKcal: perEnergyKcal, from: goalEnergyKcal)

        default:
            return nil
        }
    }
    
    //MARK: Helpers
    func calculatedQuantityForBodyMass(_ bodyMass: NutrientGoalType.BodyMass, value: Double, in weightUnit: WeightUnit) -> Double? {
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
    }
    
    func calculatedEnergyInKcal(from energy: Double?) -> Double? {
        guard let energy else { return nil }
        let energyUnit = goalSet.bodyProfile?.parameters.energyUnit ?? self.goalSet.userUnits.energy
        return energyUnit == .kcal ? energy : energy * KcalsPerKilojule
    }
}

extension NutrientType {
    func grams(equallingPercent percent: Double, of energy: Double) -> Double? {
        guard let kcalsPerGram else { return nil }
        guard percent >= 0, percent <= 100, energy > 0 else { return 0 }
        let energyPortion = energy * (percent / 100)
        return energyPortion / kcalsPerGram
    }
    
    var kcalsPerGram: Double? {
        switch self {
        case .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat, .transFat:
            return KcalsPerGramOfFat
        case .sugars, .addedSugars:
            return KcalsPerGramOfCarb
        default:
            return nil
        }
    }

}
