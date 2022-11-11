import SwiftUI
import SwiftUISugar
import PrepDataTypes
import SwiftHaptics

//MARK: - Diet

public struct Diet: Identifiable, Hashable, Codable {
    public let id: UUID
    public let isPreset: Bool
    public var isForMeal: Bool

    public var name: String
    public var goals: [Goal] = []
    
    public var syncStatus: SyncStatus
    public var updatedAt: Double
    public var deletedAt: Double?
    
    public init(id: UUID, isPreset: Bool, isForMeal: Bool, name: String, goals: [Goal], syncStatus: SyncStatus, updatedAt: Double, deletedAt: Double? = nil) {
        self.id = id
        self.isPreset = isPreset
        self.isForMeal = isForMeal
        self.name = name
        self.goals = goals
        self.syncStatus = syncStatus
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

public struct Goal: Identifiable, Hashable, Codable {
    public let id: UUID
    public let type: GoalType
    public var lowerBound: Double?
    public var upperBound: Double?
    
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
}

//MARK: - Enums

public enum BMRFormula: Int16, Hashable, Codable {
    case harrisBenedictOriginal = 1
    case harrisBenedictRevisedRozaShizgal
    case harrisBenedictRevisedMifflinStJeor
    /// add more here
}

public enum BMRType: Hashable, Codable {
    case userEntered(Double, EnergyUnit)
    case calculated(BMRFormula)
}

//TODO: Store these against a date in User object
public enum MaintenanceEnergyType: Hashable, Codable {
    case userEntered(Double, EnergyUnit)
    case calculated(BMRType, useActiveEnergyFromHealthKitWhenAvailable: Bool, activityLevel: Int)
}
/// This is a setting that gets applied on whichever date the user initially sets it on. After this, a new entry is added to their User record only once they go and change any of the parameters involved. This would then imply that whichever setting was applied takes effect until the date of the next change. We don't expect this to change often, so hopefully storing it (as a json blob on our server and data in core data) doesn't effect the size of the user's too much and outweighs having a separate entity to store records of this.
public struct UserMaintenanceEnergySetting: Hashable, Codable {
    
    /// When this setting was applied
    let date: Date
    
    /// This encompasses all the details of the maintenance energy calculation that we can then use to get a picture of
    /// any point in time (given that we have the food, exercise, and weight data.
    /// Food comes from our end (or possibly HealthKit if a user chooses to if they had been using a different service perhaps),
    /// and exercise/weight comes from HealthKit.
    let type: MaintenanceEnergyType
}

public enum EnergyGoalUnit: Int16, Hashable, Codable {
    case kcal
    case kj
    case percent
    
    var shortDescription: String {
        switch self {
        case .kcal:     return "kcal"
        case .kj:       return "kJ"
        case .percent:  return "%"
        }
    }
    
    var energyGoalType: EnergyGoalType {
        switch self {
        case .kcal, .kj:
            return .fixed
        case .percent:
            return .percentage
        }
    }
    
    init(energyUnit: EnergyUnit) {
        switch energyUnit {
        case .kcal:
            self = .kcal
        case .kJ:
            self = .kj
        }
    }
    
    init(energyGoalType: EnergyGoalType) {
        switch energyGoalType {
        case .fixed:
            self = .kcal //TODO: Use user's units
        case .percentage:
            self = .percent
        }
    }
}


public enum EnergyGoalType: Int16, Hashable, Codable, CaseIterable {
    case fixed
    case percentage
    
    //TODO: Use user's units instead of kcal
    var shortDescription: String {
        switch self {
        case .fixed:        return "kcal"
        case .percentage:   return "%"
        }
    }
    
    //TODO: Use user's units instead of kcal
    var description: String {
        switch self {
        case .fixed:        return "kcal"
        case .percentage:   return "percentage"
        }
    }
    
    var systemImage: String {
        switch self {
        case .fixed:        return "flame"
        case .percentage:   return "percent"
        }
    }
}

public enum EnergyGoalDifference: Int16, Hashable, Codable, CaseIterable {
    case surplus
    case deficit
    
    var description: String {
        switch self {
        case .deficit:  return "below maintenance"
        case .surplus:  return "above maintenance"
        }
    }
    
    var systemImage: String {
        switch self {
        case .deficit:  return "arrow.turn.right.down" // "minus.diamond"
        case .surplus:  return "arrow.turn.right.up" //"plus.diamond"
        }
    }
}

//MARK: GoalType

public enum BodyMassMesurementType: Int16, Hashable, Codable {
    case weight = 1
    case leanMass
}

public enum MacroGoalType: Codable, Hashable {
    case fixed
    case gramsPerMeasurement(BodyMassMesurementType, WeightUnit)
    case percentageOfEnergy
}

public enum MicroGoalType: Codable, Hashable {
    case fixed
}

public enum GoalType: Hashable, Codable {
    case energy(EnergyGoalUnit, EnergyGoalDifference?)
    case macro(MacroGoalType, Macro)
    case micro(MicroGoalType, NutrientType, NutrientUnit)
    
    /// A hash value that is independent of the associated values
    var identifyingHashValue: String {
        switch self {
        case .energy:
            return "energy"
        case .macro(_, let macro):
            return "macro_\(macro.rawValue)"
        case .micro(_, let nutrientType, _):
            return "macro_\(nutrientType.rawValue)"
        }
    }
    var isEnergy: Bool {
        switch self {
        case .energy:   return true
        default:        return false
        }
    }
    
    var macro: Macro? {
        switch self {
        case .macro(_, let macro):  return macro
        default:                    return nil
        }
    }
    
    var nutrientType: NutrientType? {
        switch self {
        case .micro(_, let nutrientType, _):    return nutrientType
        default:                                return nil
        }
    }
    
    var systemImage: String {
        switch self {
        case .energy:
            return "flame.fill"
        case .macro:
            return "circle.circle.fill"
        case .micro:
            return "circle.circle"
        }
    }
    
    var name: String {
        switch self {
        case .energy:
            return "Energy"
        case .macro(_, let macro):
            return macro.description
        case .micro(_, let nutrientType, _):
            return nutrientType.description
        }
    }
    
    func labelColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .energy:
            return .accentColor
        case .macro(_, let macro):
            return macro.textColor(for: colorScheme)
        case .micro:
            return .gray
        }
    }
    
    var unitString: String {
        switch self {
        case .energy(let unit, _):
            return unit.shortDescription
        case .macro:
            return "g"
        case .micro(_, _, let nutrientUnit):
            return nutrientUnit.shortDescription
        }
    }
    
    var relativeString: String? {
        switch self {
        case .energy(_, let difference):
            if let difference {
                return "\(difference.description)"
            } else {
                return nil
            }
        case .macro:
            return nil
        case .micro:
            return nil
        }
    }
    
    var differenceSystemImage: String? {
        switch self {
        case .energy(_, let difference):
            if let difference {
                return difference.systemImage
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
}

//MARK: GoalCell

struct GoalCell: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var goal: GoalViewModel
    
    var body: some View {
        ZStack {
            content
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.bottom, 10)
    }
    
    var content: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                topRow
                bottomRow
            }
        }
    }
    
    var topRow: some View {
        HStack {
            Spacer().frame(width: 2)
            HStack(spacing: 4) {
                Image(systemName: goal.type.systemImage)
                    .font(.system(size: 14))
                Text(goal.type.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            Spacer()
            differenceView
            disclosureArrow
        }
        .foregroundColor(labelColor)
    }
    
    @ViewBuilder
    var differenceView: some View {
        if let string = goal.type.relativeString,
           let icon = goal.type.differenceSystemImage
        {
            HStack {
                Image(systemName: icon)
                Text(string)
            }
            .foregroundColor(Color(.secondaryLabel))
            .font(.caption)
        }
    }
    
    var labelColor: Color {
        guard !isEmpty else {
            return Color(.secondaryLabel)
        }
        return goal.type.labelColor(for: colorScheme)
    }
    
    func amountText(_ double: Double) -> Text {
        Text("\(double.cleanAmount)")
            .foregroundColor(amountColor)
            .font(.system(size: isEmpty ? 20 : 28, weight: .medium, design: .rounded))
    }
    
    var isEmpty: Bool {
        goal.lowerBound == nil && goal.upperBound == nil
    }
    
    var amountColor: Color {
        isEmpty ? Color(.quaternaryLabel) : Color(.label)
    }

    func unitText(_ string: String) -> Text {
        Text(string)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .bold()
            .foregroundColor(Color(.secondaryLabel))
    }
    
    func amountAndUnitTexts(_ amount: Double, _ unit: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            amountText(amount)
                .multilineTextAlignment(.leading)
            if !isEmpty, let unit {
                unitText(unit)
            }
        }
    }
    
    func accessoryText(_ string: String) -> some View {
        Text(string)
            .font(.title3)
            .textCase(.lowercase)
            .foregroundColor(Color(.tertiaryLabel))
    }
    
    var bottomRow: some View {
        HStack {
            if let lowerBound = goal.lowerBound {
                if goal.upperBound == nil {
                    accessoryText("at least")
                }
                amountAndUnitTexts(lowerBound, goal.upperBound == nil ? goal.type.unitString : nil)
            } else {
                Text("Set Goal")
                    .foregroundColor(amountColor)
                    .font(.system(size: isEmpty ? 20 : 28, weight: .medium, design: .rounded))
            }
            if let upperBound = goal.upperBound {
                accessoryText(goal.lowerBound == nil ? "up to" : "to")
                amountAndUnitTexts(upperBound, goal.type.unitString)
            }
            Spacer()
        }
    }
    
    var disclosureArrow: some View {
        Image(systemName: "chevron.forward")
            .font(.system(size: 14))
            .foregroundColor(Color(.tertiaryLabel))
            .fontWeight(.semibold)
    }
}
