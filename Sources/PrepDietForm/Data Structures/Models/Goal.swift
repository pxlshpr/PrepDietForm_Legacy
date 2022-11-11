import Foundation

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
