import SwiftUI

public class GoalViewModel: ObservableObject {
    @Published var id: UUID
    @Published var type: GoalType
    @Published var lowerBound: Double?
    @Published var upperBound: Double?
    
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
    
    var energyGoalType: EnergyGoalType? {
        get {
            switch type {
            case .energy(let energyGoalUnit, _):
                return energyGoalUnit.energyGoalType
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .energy(_, let energyGoalDifference):
                self.type = .energy(
                    EnergyGoalUnit(energyGoalType: newValue),
                    energyGoalDifference
                )
            default:
                break
            }
        }
    }
    
    var energyGoalDifference: EnergyGoalDifference? {
        get {
            switch type {
            case .energy(_, let difference):
                return difference
            default:
                return nil
            }
        }
        set {
            switch type {
            case .energy(let unit, _):
                self.type = .energy(unit, newValue)
            default:
                break
            }
        }
    }
}

extension GoalViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type.identifyingHashValue)
    }
}

extension GoalViewModel: Equatable {
    public static func ==(lhs: GoalViewModel, rhs: GoalViewModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
