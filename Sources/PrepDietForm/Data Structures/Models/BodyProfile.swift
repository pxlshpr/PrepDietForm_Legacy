import Foundation
import PrepDataTypes
import HealthKit

public struct BodyProfile: Hashable, Codable {
    
    public let id: UUID
    
    public var parameters: Parameters
    
    public var syncStatus: SyncStatus
    public var updatedAt: Double
    
}

extension BodyProfile {
    
    public struct Parameters: Hashable, Codable {
        
        let energyUnit: EnergyUnit
        let weightUnit: WeightUnit
        let heightUnit: HeightUnit

        var restingEnergy: Double?
        var restingEnergySource: RestingEnergySourceOption?
        var restingEnergyFormula: RestingEnergyFormula?
        var restingEnergyPeriod: HealthPeriodOption?
        var restingEnergyIntervalValue: Int?
        var restingEnergyInterval: HealthAppInterval?

        var activeEnergy: Double?
        var activeEnergySource: ActiveEnergySourceOption?
        var activeEnergyActivityLevel: ActivityLevel?
        var activeEnergyPeriod: HealthPeriodOption?
        var activeEnergyIntervalValue: Int?
        var activeEnergyInterval: HealthAppInterval?

        var fatPercentage: Double?

        var lbm: Double?
        var lbmSource: LeanBodyMassSourceOption?
        var lbmFormula: LeanBodyMassFormula?
        var lbmDate: Date?

        var weight: Double?
        var weightSource: MeasurementSourceOption?
        var weightDate: Date?

        var height: Double?
        var heightSource: MeasurementSourceOption?
        var heightDate: Date?

        var sexIsFemale: Bool?
        var sexSource: MeasurementSourceOption?

        var age: Int?
        var dob: DateComponents?
        var ageSource: MeasurementSourceOption?
    }
}

extension BodyProfile.Parameters {
    var updatesWithHealthApp: Bool {
        return restingEnergySource == .healthApp
        || activeEnergySource == .healthApp
        || lbmSource == .healthApp
        || weightSource == .healthApp
    }
}

extension BodyProfile {
    
    var hasTDEE: Bool {
        tdeeInUnit != nil
    }
    
    var tdeeInUnit: Double? {
        parameters.tdee
    }
    var formattedTDEEWithUnit: String? {
        guard let tdeeInUnit else { return nil }
        return "\(tdeeInUnit.formattedEnergy) \(parameters.energyUnit.shortDescription)"
    }
    
    func tdee(in energyUnit: EnergyUnit) -> Double? {
        parameters.tdee(in: energyUnit)
    }
    
    func weight(in other: WeightUnit) -> Double? {
        parameters.weight(in: other)
    }
    
    func lbm(in other: WeightUnit) -> Double? {
        parameters.lbm(in: other)
    }

    var hasDynamicTDEE: Bool {
        parameters.hasDynamicTDEE
    }
}

extension WeightUnit {
    func convert(_ value: Double, to other: WeightUnit) -> Double {
        let inGrams = value * self.g
        return inGrams / other.g
    }
}

extension BodyProfile.Parameters {
    
    var hasDynamicRestingEnergy: Bool {
        switch restingEnergySource {
        case .healthApp:
            return true
        case .formula:
            guard let restingEnergyFormula else { return false }
            if restingEnergyFormula.usesLeanBodyMass, hasDynamicLBM {
                return hasDynamicLBM
            } else {
                return hasDynamicWeight
            }
        default:
            return false
        }
    }
    
    var hasDynamicActiveEnergy: Bool {
        switch activeEnergySource {
        case .healthApp:
            return true
        default:
            return false
        }
    }
    
    var hasDynamicTDEE: Bool {
        hasDynamicRestingEnergy || hasDynamicActiveEnergy
    }
    
    var hasDynamicLBM: Bool {
        guard let lbmSource else { return false }
        switch lbmSource {
        case .healthApp:
            return true
        case .fatPercentage, .formula:
            /// We don't care about the height being dynamic as it hardly changes after age 18-20
            return hasDynamicWeight
        default:
            return false
        }
    }
    
    var hasDynamicWeight: Bool {
        weightSource == .healthApp
    }
    
    func weight(in other: WeightUnit) -> Double? {
        guard let weight else { return nil }
        return weightUnit.convert(weight, to: other)
    }
    
    func lbm(in other: WeightUnit) -> Double? {
        guard let lbm else { return nil }
        return weightUnit.convert(lbm, to: other)
    }

    func tdee(in energyUnit: EnergyUnit) -> Double? {
        guard let tdeeInKcal else { return nil }
        return energyUnit == .kcal ? tdeeInKcal : tdeeInKcal * KcalsPerKilojule
    }

    var tdee: Double? {
        guard let restingEnergy, let activeEnergy else { return nil }
        return restingEnergy + activeEnergy
    }
    
    var tdeeInKcal: Double? {
        guard let tdee else { return nil }
        if energyUnit == .kcal {
            return tdee
        } else {
            return tdee / KcalsPerKilojule
        }
    }
}
