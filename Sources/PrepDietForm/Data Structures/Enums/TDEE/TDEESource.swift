//import PrepDataTypes
//
//public enum TDEESource: Hashable, Codable {
//    case userEntered(Double, EnergyUnit)
//    case formula(RestingEnergyFormula, activityLevel: ActivityLevel?)
//    
//    /// This is for when we use HealthKit's resting energy.
//    /// The `numberOfPastDaysToConsider` allows the user to use an average of the past 7, 30, whatever days instead of each day individually,
//    /// so that days of not wearing the Apple Watch may be accounted for.
//    case healthKit(numberOfPastDaysToConsider: Int)
//}
//
