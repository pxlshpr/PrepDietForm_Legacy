import Foundation
import PrepDataTypes

struct UserUnits {
    let energy: EnergyUnit
    let weight: WeightUnit
    let height: HeightUnit
    
    static var standard: UserUnits {
        UserUnits(energy: .kcal, weight: .kg, height: .cm)
    }
}
