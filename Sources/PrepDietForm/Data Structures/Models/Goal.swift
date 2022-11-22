import Foundation
import PrepDataTypes

public struct Goal: Identifiable, Hashable, Codable {
    public let id: UUID
    public let type: GoalType
    public var lowerBound: Double?
    public var upperBound: Double?
    
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
}

extension Array where Element == Goal {
    func goalViewModels(goalSet: GoalSetViewModel, isForMeal: Bool) -> [GoalViewModel] {
        map {
            GoalViewModel(
                goalSet: goalSet,
                isForMeal: isForMeal,
                id: $0.id,
                type: $0.type,
                lowerBound: $0.lowerBound,
                upperBound: $0.upperBound
            )
        }
    }
}

extension Goal {
    
    func equivalentLowerBound(
        energyGoal: Goal?,
        bodyProfile: BodyProfile?,
        userUnits: UserUnits
    ) -> Double? {
        
        let energyValue = energyGoalLowerOrUpper(
            energyGoal: energyGoal,
            bodyProfile: bodyProfile,
            userUnits: userUnits
        )
        
        switch type {
        case .energy:
            return calculateEnergyValue(
                from: lowerBound,
                deficitBound: largerBound ?? lowerBound,
                tdee: bodyProfile?.tdeeInUnit
            )
        case .macro:
            return calculateMacroValue(
                from: trueLowerBound,
                energy: energyValue,
                bodyProfile: bodyProfile,
                userUnits: userUnits
            )

        case .micro:
            return calculateMicroValue(
                from: trueLowerBound,
                energy: energyValue,
                bodyProfile: bodyProfile,
                userUnits: userUnits
            )
        }
    }
    
    func equivalentUpperBound(
        energyGoal: Goal?,
        bodyProfile: BodyProfile?,
        userUnits: UserUnits
    ) -> Double? {
        
        let energyValue = energyGoalUpperOrLower(
            energyGoal: energyGoal,
            bodyProfile: bodyProfile,
            userUnits: userUnits
        )

        switch type {
        case .energy:
            return calculateEnergyValue(
                from: upperBound,
                deficitBound: smallerBound ?? upperBound,
                tdee: bodyProfile?.tdeeInUnit
            )
        case .macro:
            return calculateMacroValue(
                from: trueUpperBound,
                energy: energyValue,
                bodyProfile: bodyProfile,
                userUnits: userUnits
            )
        case .micro:
            return calculateMicroValue(
                from: trueUpperBound,
                energy: energyValue,
                bodyProfile: bodyProfile,
                userUnits: userUnits
            )
        }
    }
}

extension Goal {
    
    func energyGoalLowerOrUpper(
        energyGoal: Goal?,
        bodyProfile: BodyProfile?,
        userUnits: UserUnits
    ) -> Double? {
        guard let energyGoal else { return nil }
        return energyGoal.equivalentLowerBound(
            energyGoal: energyGoal,
            bodyProfile: bodyProfile,
            userUnits: userUnits
        ) ?? energyGoal.equivalentUpperBound(
            energyGoal: energyGoal,
            bodyProfile: bodyProfile,
            userUnits: userUnits
        )
    }
    
    func energyGoalUpperOrLower(
        energyGoal: Goal?,
        bodyProfile: BodyProfile?,
        userUnits: UserUnits
    ) -> Double? {
        guard let energyGoal else { return nil }
        return energyGoal.equivalentUpperBound(
            energyGoal: energyGoal,
            bodyProfile: bodyProfile,
            userUnits: userUnits
        ) ?? energyGoal.equivalentLowerBound(
            energyGoal: energyGoal,
            bodyProfile: bodyProfile,
            userUnits: userUnits
        )
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
    
    var largerBound: Double? {
        if let upperBound {
            if let lowerBound {
                return upperBound > lowerBound ? upperBound : lowerBound
            } else {
                return upperBound
            }
        } else {
            return lowerBound
        }
    }
    
    var smallerBound: Double? {
        if let upperBound {
            if let lowerBound {
                return upperBound < lowerBound ? upperBound : lowerBound
            } else {
                return upperBound
            }
        } else {
            return lowerBound
        }
    }
}

extension Goal {

 
    func calculateEnergyValue(
        from value: Double?,
        deficitBound: Double?,
        tdee: Double?
    ) -> Double? {
        guard let value, let energyGoalType else { return nil }
        
        guard !energyGoalType.isFixed else {
            return value
        }
        
        guard let deficitBound, let tdee else { return nil }
        
        switch energyGoalType {
        case .fromMaintenance(_, let delta):
            switch delta {
            case .deficit:
                return tdee - deficitBound
            case .surplus:
                return tdee + value
            }
            
        case .percentFromMaintenance(let delta):
            switch delta {
            case .deficit:
                return tdee - ((deficitBound/100) * tdee)
            case .surplus:
                return tdee + ((value/100) * tdee)
            }
            
        default:
            return nil
        }
    }
    
    func calculateMacroValue(
        from value: Double?,
        energy: Double?,
        bodyProfile: BodyProfile?,
        userUnits: UserUnits
    ) -> Double? {
        
        guard let nutrientGoalType, nutrientGoalType.isPercentageOfEnergy else {
            return calculateNutrientValue(
                from: value,
                energy: energy,
                bodyProfile: bodyProfile,
                userUnits: userUnits
            )
        }
        
        guard let macro,
              let value,
              let energyInKcal = convertEnergyToKcal(
                    energy,
                    usingBodyProfile: bodyProfile,
                    orUserUnits: userUnits
              )
        else { return nil }
        
        return macro.grams(equallingPercent: value, of: energyInKcal)
    }
    
    func calculateMicroValue(
        from value: Double?,
        energy: Double?,
        bodyProfile: BodyProfile?,
        userUnits: UserUnits
    ) -> Double? {
        
        guard let nutrientGoalType, nutrientGoalType.isPercentageOfEnergy else {
            return calculateNutrientValue(
                from: value,
                energy: energy,
                bodyProfile: bodyProfile,
                userUnits: userUnits
            )
        }

        guard let nutrientType,
              let value,
              let energyInKcal = convertEnergyToKcal(
                    energy,
                    usingBodyProfile: bodyProfile,
                    orUserUnits: userUnits
              )
        else { return nil }
        
        return nutrientType.grams(equallingPercent: value, of: energyInKcal)
    }
    
    func calculateNutrientValue(
        from value: Double?,
        energy: Double?,
        bodyProfile: BodyProfile?,
        userUnits: UserUnits
    ) -> Double? {
        guard let value, let nutrientGoalType else { return nil }
        
        switch nutrientGoalType {
            
        case .quantityPerBodyMass(let bodyMass, let weightUnit):
            switch bodyMass {
            case .weight:
                guard let weight = bodyProfile?.weight(in: weightUnit)
                else { return nil }
                return value * weight
                
            case .leanMass:
                guard let lbm = bodyProfile?.lbm(in: weightUnit)
                else { return nil}
                return value * lbm
                
            }
            
        case .quantityPerEnergy(let perEnergy, let energyUnit):
            guard let goalEnergyKcal = convertEnergyToKcal(
                energy,
                usingBodyProfile: bodyProfile,
                orUserUnits: userUnits
            ) else {
                return nil
            }
            
            let perEnergyInKcal: Double
            if energyUnit == .kcal {
                perEnergyInKcal = perEnergy
            } else {
                perEnergyInKcal = EnergyUnit.convertToKilocalories(fromKilojules: perEnergy)
            }
            return (value * goalEnergyKcal) / perEnergyInKcal
            
        default:
            return nil
        }
    }
    
    //MARK: - Helpers
    func convertEnergyToKcal(
        _ energy: Double?,
        usingBodyProfile bodyProfile: BodyProfile?,
        orUserUnits userUnits: UserUnits
    ) -> Double? {
        guard let energy else { return nil }
        let energyUnit = bodyProfile?.parameters.energyUnit ?? userUnits.energy
        return energyUnit == .kcal ? energy : energy * KcalsPerKilojule
    }

    var energyGoalType: EnergyGoalType? {
        switch type {
        case .energy(let type):
            return type
        default:
            return nil
        }
    }
    
    var nutrientGoalType: NutrientGoalType? {
        switch type {
        case .macro(let type, _):
            return type
        case .micro(let type, _, _):
            return type
        default:
            return nil
        }
    }
    
    var macro: Macro? {
        switch type {
        case .macro(_, let macro):
            return macro
        default:
            return nil
        }
    }

    var nutrientType: NutrientType? {
        switch type {
        case .micro(_, let nutrientType, _):
            return nutrientType
        default:
            return nil
        }
    }

}
