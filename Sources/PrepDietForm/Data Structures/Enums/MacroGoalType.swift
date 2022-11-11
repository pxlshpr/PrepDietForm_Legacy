import PrepDataTypes

public enum MacroGoalType: Codable, Hashable {
    case fixed
    case gramsPerMeasurement(BodyMassMesurementType, WeightUnit)
    case percentageOfEnergy
}
