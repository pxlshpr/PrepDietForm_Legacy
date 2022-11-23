import Foundation
import PrepDataTypes

public struct GoalSet: Identifiable, Hashable, Codable {
    
    public let id: UUID

    public var name: String
    public var emoji: String
    public var goals: [Goal] = []
    public var isMealProfile: Bool

    public let isPreset: Bool

    public var syncStatus: SyncStatus
    public var updatedAt: Double
    public var deletedAt: Double?
    
    public init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        goals: [Goal] = [],
        isMealProfile: Bool = false,
        isPreset: Bool = false,
        syncStatus: SyncStatus = .notSynced,
        updatedAt: Double = Date().timeIntervalSinceNow,
        deletedAt: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.goals = goals
        self.isMealProfile = isMealProfile
        self.isPreset = isPreset
        self.syncStatus = syncStatus
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension GoalSet {
    var energyGoal: Goal? {
        goals.first(where: { $0.type.isEnergy })
    }
    
    /// Creates an auto energy goal if we have goals for all 3 macros
    func autoEnergyGoal(with params: GoalCalcParams) -> Goal? {
        calculateMissingGoal(
            energy: nil,
            carb: carbGoal,
            fat: fatGoal,
            protein: proteinGoal,
            with: params
        )
    }
    
    var carbGoal: Goal? { goals.first(where: { $0.type.macro == .carb }) }
    var fatGoal: Goal? { goals.first(where: { $0.type.macro == .fat }) }
    var proteinGoal: Goal? { goals.first(where: { $0.type.macro == .protein }) }
}

struct GoalCalcParams {
    let userUnits: UserUnits
    let bodyProfile: BodyProfile?
    let energyGoal: Goal?
}

func calculateMissingGoal(
    energy: Goal?,
    carb: Goal?,
    fat: Goal?,
    protein: Goal?,
    with params: GoalCalcParams
) -> Goal? {
    if energy == nil {
        /// Calculate energy
        guard let carb, let fat, let protein else { return nil }
        guard let carbLower = carb.lowerOrUpper(with: params),
              let carbUpper = carb.upperOrLower(with: params),
              let fatLower = fat.lowerOrUpper(with: params),
              let fatUpper = fat.upperOrLower(with: params),
              let proteinLower = protein.lowerOrUpper(with: params),
              let proteinUpper = protein.upperOrLower(with: params)
        else { return nil }
        
        let lower = calculateEnergy(c: carbLower, f: fatLower, p: proteinLower)
        let upper = calculateEnergy(c: carbUpper, f: fatUpper, p: proteinUpper)

        let goal = Goal(
            type: .energy(.fixed(params.userUnits.energy)),
            lowerBound: lower.rounded(toPlaces: 2) == upper.rounded(toPlaces: 2) ? nil : lower,
            upperBound: upper
        )
        
        return goal
    }
    return nil
}

func calculateEnergy(c: Double, f: Double, p: Double) -> Double {
    (c * KcalsPerGramOfCarb) + (f * KcalsPerGramOfFat) + (p * KcalsPerGramOfProtein)
}
