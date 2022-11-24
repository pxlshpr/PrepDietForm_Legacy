import Foundation
import PrepDataTypes

struct UserUnits: Hashable, Codable {
    let energy: EnergyUnit
    let weight: WeightUnit
    let height: HeightUnit
    let volume: UserExplicitVolumeUnits
    
    static var standard: UserUnits {
        UserUnits(
            energy: .kcal,
            weight: .kg,
            height: .cm,
            volume: .defaultUnits
        )
    }
}
