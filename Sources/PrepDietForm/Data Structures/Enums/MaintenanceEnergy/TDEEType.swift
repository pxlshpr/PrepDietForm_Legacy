import PrepDataTypes

//TODO: Store these against a date in User object
public enum TDEEType: Hashable, Codable {
    case userEntered(Double, EnergyUnit)
    case calculated(BMRType, useActiveEnergyFromHealthKitWhenAvailable: Bool, activityLevel: Int)
}
