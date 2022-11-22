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

extension Array where Element == Goal {
    func goalViewModels(goalSet: GoalSetViewModel, isForMeal: Bool) -> [GoalViewModel] {
        map {
            GoalViewModel(
                goalSet: goalSet,
                isForMeal: isForMeal,
                id: $0.id,
                type: $0.type,
                lowerBound: $0.lowerBound,
                upperBound: $0.upperBound
            )
        }
    }
}
