import Foundation
import PrepDataTypes

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
