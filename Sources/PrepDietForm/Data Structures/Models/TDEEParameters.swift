import Foundation
import PrepDataTypes
import HealthKit

public struct TDEEProfile: Hashable, Codable {
    
    public let id: UUID
    
    public var tdeeInKcal: Double
    public var parameters: TDEEProfileParameters
    
    public var syncStatus: SyncStatus
    public var updatedAt: Double
}

public struct TDEEProfileParameters: Hashable, Codable {
    /// The units being used at the time of creating this profile
    let energyUnit: EnergyUnit
    let weightUnit: WeightUnit
    let heightUnit: HeightUnit

    var restingEnergy: Double
    let restingEnergySource: RestingEnergySourceOption
    var restingEnergyFormula: RestingEnergyFormula?
    var restingEnergyPeriod: HealthPeriodOption?
    var restingEnergyIntervalValue: Int?
    var restingEnergyInterval: HealthAppInterval?

    var activeEnergy: Double
    var activeEnergySource: ActiveEnergySourceOption
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
