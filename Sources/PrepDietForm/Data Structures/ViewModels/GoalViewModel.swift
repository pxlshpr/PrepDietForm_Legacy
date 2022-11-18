import SwiftUI
import PrepDataTypes

public class GoalViewModel: ObservableObject {
    
    var goalSet: GoalSetForm.ViewModel
    
    let isForMeal: Bool
    
    let id: UUID
    @Published var type: GoalType
    @Published var lowerBound: Double?
    @Published var upperBound: Double?
    
    public init(
        goalSet: GoalSetForm.ViewModel,
        isForMeal: Bool = false,
        id: UUID = UUID(),
        type: GoalType,
        lowerBound: Double? = nil,
        upperBound: Double? = nil
    ) {
        self.goalSet = goalSet
        self.isForMeal = isForMeal
        self.id = id
        self.type = type
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }
    
    //MARK: - Energy
    var energyGoalType: EnergyGoalType? {
        get {
            switch type {
            case .energy(let type):
                return type
            default:
                return nil
            }
        }
        set {
            guard let newValue else { return }
            switch type {
            case .energy:
                self.type = .energy(newValue)
            default:
                break
            }
        }
    }
    
    var haveEquivalentValues: Bool {
        equivalentLowerBound != nil || equivalentUpperBound != nil
    }
    var energyGoalDelta: EnergyGoalType.Delta? {
        get {
            switch type {
            case .energy(let type):
                return type.delta
            default:
                return nil
            }
        }
        set {
            switch type {
            case .energy(let type):
                //TODO: Set the type here
                var new = type
                new.delta = newValue
                self.type = .energy(new)
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
    
    var macroBodyMassType: MacroGoalType.BodyMass? {
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

    var bodyMassUnit: WeightUnit? {
        switch type {
        case .macro(let macroGoalType, _):
            switch macroGoalType {
            case .gramsPerBodyMass(_, let weightUnit):
                return weightUnit
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    var bodyMassType: MacroGoalType.BodyMass? {
        switch type {
        case .macro(let macroGoalType, _):
            switch macroGoalType {
            case .gramsPerBodyMass(let bodyMassType, _):
                return bodyMassType
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    var energyUnit: EnergyUnit? {
        switch energyGoalType {
        case .fixed(let energyUnit):
            return energyUnit
        case .fromMaintenance(let energyUnit, _):
            return energyUnit
        default:
            return nil
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
