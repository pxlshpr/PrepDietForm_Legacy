import Foundation
import PrepDataTypes

public enum DietMacroGoalType: Codable, Hashable {
    case fixed
    case gramsPerBodyMass(BodyMassType, WeightUnit)
    case percentageOfEnergy
}

