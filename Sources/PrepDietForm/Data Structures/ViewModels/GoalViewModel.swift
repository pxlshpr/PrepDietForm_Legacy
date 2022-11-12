import SwiftUI
import PrepDataTypes

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
    
    //MARK: - Energy
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
    
    var energyGoalDifference: EnergyDelta? {
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
    
    //MARK: - Macro
    var macro: Macro? {
        switch type {
        case .macro(_, let macro):
            return macro
        default:
            return nil
        }
    }
    
    var macroGoalType: MacroGoalType? {
        get {
            switch type {
            case .macro(let type, _):
                return type
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .macro(_, let macro):
                self.type = .macro(newValue, macro)
            default:
                break
            }
        }
    }
    
    var macroBodyMassType: BodyMassType? {
        get {
            switch type {
            case .macro(let type, _):
                return type.bodyMassType
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .macro(let macroGoalType, let macro):
                var new = macroGoalType
                new.bodyMassType = newValue
                self.type = .macro(new, macro)
            default:
                break
            }
        }
    }
    
    var macroBodyMassWeightUnit: WeightUnit? {
        get {
            switch type {
            case .macro(let type, _):
                return type.bodyMassWeightUnit
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .macro(let macroGoalType, let macro):
                var new = macroGoalType
                new.bodyMassWeightUnit = newValue
                self.type = .macro(new, macro)
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
