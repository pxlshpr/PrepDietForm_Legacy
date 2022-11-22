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
}
