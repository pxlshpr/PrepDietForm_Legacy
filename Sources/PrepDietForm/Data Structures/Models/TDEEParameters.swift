import Foundation

/// This is a setting that gets applied on whichever date the user initially sets it on. After this, a new entry is added to their User record only once they go and change any of the parameters involved. This would then imply that whichever setting was applied takes effect until the date of the next change. We don't expect this to change often, so hopefully storing it (as a json blob on our server and data in core data) doesn't effect the size of the user's too much and outweighs having a separate entity to store records of this.
public struct TDEEParameters: Hashable, Codable {
    
    /// When this setting was applied
    let date: Date
    
    /// This encompasses all the details of the maintenance energy calculation that we can then use to get a picture of
    /// any point in time (given that we have the food, exercise, and weight data.
    /// Food comes from our end (or possibly HealthKit if a user chooses to if they had been using a different service perhaps),
    /// and exercise/weight comes from HealthKit.
    let source: TDEESource
    
    //TODO: Add remainingt things from the form when done (like use activity etc)
    //TODO: Consider removing associated values from source and place them here to make life easier for us
}
