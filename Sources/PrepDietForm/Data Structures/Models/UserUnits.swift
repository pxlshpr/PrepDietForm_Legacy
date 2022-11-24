import Foundation
import PrepDataTypes

struct UserUnits: Hashable, Codable {
    let energyUnit: EnergyUnit
    let weightUnit: WeightUnit
    let heightUnit: HeightUnit
    let explicitVolumeUnits: UserExplicitVolumeUnits
    
    static var standard: UserUnits {
        UserUnits(
            energyUnit: .kcal,
            weightUnit: .kg,
            heightUnit: .cm,
            explicitVolumeUnits: .defaultUnits
        )
    }
}
