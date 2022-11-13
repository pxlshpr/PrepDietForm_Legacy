import PrepDataTypes

public enum BMRType: Hashable, Codable {
    case userEntered(Double, EnergyUnit)
    case calculated(BMREquation)
}
