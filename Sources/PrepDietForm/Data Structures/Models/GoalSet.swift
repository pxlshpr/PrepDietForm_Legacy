import Foundation
import PrepDataTypes

public struct GoalSet: Identifiable, Hashable, Codable {
    
    public let id: UUID

    public var name: String
    public var emoji: String
    public var goals: [Goal] = []
    public var isMealProfile: Bool

    public let isPreset: Bool

    public var syncStatus: SyncStatus
    public var updatedAt: Double
    public var deletedAt: Double?
    
    public init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        goals: [Goal] = [],
        isMealProfile: Bool = false,
        isPreset: Bool = false,
        syncStatus: SyncStatus = .notSynced,
        updatedAt: Double = Date().timeIntervalSinceNow,
        deletedAt: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.goals = goals
        self.isMealProfile = isMealProfile
        self.isPreset = isPreset
        self.syncStatus = syncStatus
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

//extension Goal {
//
//    func calculatedLowerBound(
//
//        inGoalSet goalSet: GoalSet,
//        userUnits: UserUnits,
//        withBodyProfile bodyProfile: BodyProfile?
//
//    ) -> Double? {
//
//        switch type {
//        case .energy(let energyGoalType):
//            switch energyGoalType {
//
//            case .fromMaintenance(let energyUnit, let delta):
//                guard let tdee = bodyProfile?.tdee(in: energyUnit) else { return nil }
//                switch delta {
//                case .deficit:
//                    if let upperBound, let lowerBound {
//                        if upperBound > lowerBound {
//                            return tdee - upperBound
//                        } else {
//                            return tdee - lowerBound
//                        }
//                    } else {
//                        guard let lowerBound else { return nil }
//                        return tdee - lowerBound
//                    }
//                case .surplus:
//                    guard let lowerBound else { return nil }
//                    return tdee + lowerBound
//                }
//
//            case .percentFromMaintenance(let delta):
//                guard let tdee = bodyProfile?.tdeeInUnit else { return nil }
//                switch delta {
//                case .deficit:
//                    if let upperBound, let lowerBound {
//                        if upperBound > lowerBound {
//                            return tdee - ((upperBound/100) * tdee)
//                        } else {
//                            return tdee - ((lowerBound/100) * tdee)
//                        }
//                    } else {
//                        guard let lowerBound else { return nil }
//                        return tdee - ((lowerBound/100) * tdee)
//                    }
//                case .surplus:
//                    guard let lowerBound else { return nil }
//                    return tdee + ((lowerBound/100) * tdee)
//                }
//
//            case .fixed:
//                return lowerBound
//            }
//
//        case .macro(let nutrientGoalType, let macro):
//            guard let trueLowerBound else  {
//                return nil
//            }
//            return macroValue(
//                from: trueLowerBound,
//                for: nutrientGoalType,
//                macro: macro,
//                energy: goalSet.energyGoal?.equivalentLowerBound ?? goalSet.energyGoal?.equivalentUpperBound
//            )
//
//        case .micro(let nutrientGoalType, let nutrientType, _):
//            guard let trueLowerBound else  {
//                return nil
//            }
//            return microValue(
//                from: trueLowerBound,
//                for: nutrientGoalType,
//                nutrientType: nutrientType,
//                energy: goalSet.energyGoal?.equivalentLowerBound ?? goalSet.energyGoal?.equivalentUpperBound
//            )
//        }
//    }
//
//    var trueLowerBound: Double? {
//        guard let lowerBound else { return nil }
//        guard let upperBound else { return lowerBound }
//        if upperBound == lowerBound {
//            return nil
//        }
//        if upperBound < lowerBound {
//            return upperBound
//        }
//        return lowerBound
//    }
//
//    var trueUpperBound: Double? {
//        guard let upperBound else { return nil }
//        guard let lowerBound else { return upperBound }
//        if upperBound == lowerBound {
//            return upperBound
//        }
//        if lowerBound > upperBound {
//            return lowerBound
//        }
//        return upperBound
//    }
//
//    func macroValue(
//
//        from value: Double,
//        for nutrientGoalType: NutrientGoalType,
//        macro: Macro,
//        energy: Double?
//
//    ) -> Double? {
//        switch nutrientGoalType {
//        case .quantityPerBodyMass(let bodyMass, let weightUnit):
//            return calculatedQuantityForBodyMass(bodyMass, value: value, in: weightUnit)
//
//        case .percentageOfEnergy:
//            guard let energyInKcal = calculatedEnergyInKcal(from: energy) else { return nil }
//            return macro.grams(equallingPercent: value, of: energyInKcal)
//
//        case .quantityPerEnergy(let energyValue, let energyUnit):
//            guard let goalEnergyKcal = calculatedEnergyInKcal(from: energy) else { return nil }
//            let perEnergyKcal = energyUnit == .kcal ? energyValue : EnergyUnit.convertToKilocalories(fromKilojules: energyValue)
//            return calculatedQuantityPerEnergy(value: value, perEnergyKcal: perEnergyKcal, from: goalEnergyKcal)
//        default:
//            return nil
//        }
//    }
//
//    /// Returns this in grams
//    func microValue(from value: Double, for nutrientGoalType: NutrientGoalType, nutrientType: NutrientType, energy: Double?) -> Double? {
//        switch nutrientGoalType {
//        case .quantityPerBodyMass(let bodyMass, let weightUnit):
//            return calculatedQuantityForBodyMass(bodyMass, value: value, in: weightUnit)
//
//        case .percentageOfEnergy:
//            guard let energyInKcal = calculatedEnergyInKcal(from: energy) else { return nil }
//            return nutrientType.grams(equallingPercent: value, of: energyInKcal)
//
//        case .quantityPerEnergy(let energyValue, let energyUnit):
//            guard let goalEnergyKcal = calculatedEnergyInKcal(from: energy) else { return nil }
//            let perEnergyKcal = energyUnit == .kcal ? energyValue : EnergyUnit.convertToKilocalories(fromKilojules: energyValue)
//            return calculatedQuantityPerEnergy(value: value, perEnergyKcal: perEnergyKcal, from: goalEnergyKcal)
//
//        default:
//            return nil
//        }
//    }
//
//    func calculatedQuantityPerEnergy(value: Double, perEnergyKcal: Double, from goalEnergyKcal: Double) -> Double? {
//        guard perEnergyKcal > 0 else { return nil }
//        return (value * goalEnergyKcal) / perEnergyKcal
//    }
//
//    func calculatedQuantityForBodyMass(
//
//        _ bodyMass: NutrientGoalType.BodyMass,
//        value: Double,
//        in weightUnit: WeightUnit,
//        
//        inGoalSet goalSet: GoalSet,
//        userUnits: UserUnits,
//        withBodyProfile bodyProfile: BodyProfile?
//
//
//    ) -> Double? {
//
//        switch bodyMass {
//        case .weight:
//            guard let weight = goalSet.bodyProfile?.weight(in: weightUnit)
//            else { return nil }
//            return value * weight
//
//        case .leanMass:
//            guard let lbm = goalSet.bodyProfile?.lbm(in: weightUnit)
//            else { return nil}
//            return value * lbm
//
//        }
//    }
//
//    func calculatedEnergyInKcal(
//
//        from energy: Double?,
//        
//        inGoalSet goalSet: GoalSet,
//        userUnits: UserUnits,
//        withBodyProfile bodyProfile: BodyProfile?
//
//    ) -> Double? {
//
//        guard let energy else { return nil }
//        let energyUnit = bodyProfile?.parameters.energyUnit ?? userUnits.energy
//        return energyUnit == .kcal ? energy : energy * KcalsPerKilojule
//    }
//}
