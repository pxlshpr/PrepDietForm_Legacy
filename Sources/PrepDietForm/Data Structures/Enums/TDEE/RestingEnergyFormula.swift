import Foundation
import PrepDataTypes
import HealthKit

public enum RestingEnergyFormula: Int16, Hashable, Codable, CaseIterable {
    case katchMcardle = 1
    case henryOxford
    case mifflinStJeor
    case schofield
    case cunningham
    case rozaShizgal
    case harrisBenedict

    static var latest: [RestingEnergyFormula] {
        [.henryOxford, .katchMcardle, .mifflinStJeor, .schofield]
    }

    static var legacy: [RestingEnergyFormula] {
        [.rozaShizgal, .cunningham, .harrisBenedict]
    }

    var pickerDescription: String {
        switch self {
        case .schofield:
            return "Schofield (WHO)"
        case .henryOxford:
            return "Henry Oxford"
        case .harrisBenedict:
            return "Harris-Benedict"
        case .cunningham:
            return "Cunningham"
        case .rozaShizgal:
            return "Roza-Shizgal (Harris-Benedict Revised)"
        case .mifflinStJeor:
            return "Mifflin-St. Jeor"
        case .katchMcardle:
            return "Katch-McArdle"
        }
    }
    
    var menuDescription: String {
        switch self {
        case .schofield:
            return "Schofield"
        case .henryOxford:
            return "Oxford"
        case .harrisBenedict:
            return "Harris-Benedict"
        case .cunningham:
            return "Cunningham"
        case .rozaShizgal:
            return "Roza-Shizgal"
        case .mifflinStJeor:
            return "Mifflin-St. Jeor"
        case .katchMcardle:
            return "Katch-McArdle"
        }
    }
    var year: String {
        switch self {
        case .schofield:
            return "1985"
        case .henryOxford:
            return "2005"
        case .harrisBenedict:
            return "1919"
        case .cunningham:
            return "1980"
        case .rozaShizgal:
            return "1984"
        case .mifflinStJeor:
            return "1990"
        case .katchMcardle:
            return "1996"
        }
    }
}

extension RestingEnergyFormula {
    func calculate(lbmInKg: Double, energyUnit: EnergyUnit) -> Double? {
        let energy: Double
        switch self {
        case .katchMcardle:
            energy = 370 + (21.6 * lbmInKg)
        case .cunningham:
            energy = 500 + (22.0 * lbmInKg)
        default:
            return nil
        }
        return energyUnit == .kJ ? energy * KcalsPerKilojule : energy
    }

    func calculate(age: Int, weightInKg: Double, sex: HKBiologicalSex, energyUnit: EnergyUnit) -> Double? {
        let energy: Double
        let ageGroup = AgeGroup(age)
        switch self {
            
        case .henryOxford:
            let a = OxfordCoefficients.a(sex: sex, ageGroup: ageGroup)
            let c = OxfordCoefficients.c(sex: sex, ageGroup: ageGroup)
            energy = (a * weightInKg) + c
            
        case .schofield:
            let a = SchofieldCoefficients.a(sex: sex, ageGroup: ageGroup)
            let c = SchofieldCoefficients.c(sex: sex, ageGroup: ageGroup)
            energy = (a * weightInKg) + c

        default:
            return nil
        }
        return energyUnit == .kJ ? energy * KcalsPerKilojule : energy
    }
    
    func calculate(age: Int, weightInKg: Double, heightInCm: Double, sex: HKBiologicalSex, energyUnit: EnergyUnit) -> Double? {
        let energy: Double
        switch self {
            
        case .henryOxford:
            return calculate(age: age, weightInKg: weightInKg, sex: sex, energyUnit: energyUnit)
        case .schofield:
            return calculate(age: age, weightInKg: weightInKg, sex: sex, energyUnit: energyUnit)

        case .mifflinStJeor:
            if sex == .female {
                energy = (9.99 * weightInKg) + (6.25 * heightInCm) - (4.92 * Double(age)) - 161
            } else {
                energy = (9.99 * weightInKg) + (6.25 * heightInCm) - (4.92 * Double(age)) + 5
            }
            
        case .rozaShizgal:
            if sex == .female {
                energy = 447.593 + (9.247 * weightInKg) + (3.098 * heightInCm) - (4.33 * Double(age))
            } else {
                energy = 88.362 + (13.397 * weightInKg) + (4.799 * heightInCm) - (5.677 * Double(age))
            }

        case .harrisBenedict:
            if sex == .female {
                energy = 655.0955 + (9.5634 * weightInKg) + (1.8496 * heightInCm) - (4.6756 * Double(age))
            } else {
                energy = 66.4730 + (13.7516 * weightInKg) + (5.0033 * heightInCm) - (6.7550 * Double(age))
            }
            
        default:
            return nil
        }
        return energyUnit == .kJ ? energy * KcalsPerKilojule : energy
    }
}

enum AgeGroup {
    case zeroToTwo
    case threeToNine
    case tenToSeventeen
    case eighteenToTwentyNine
    case thirtyToFiftyNine
    case sixtyAndOver
    
    init(_ age: Int) {
        switch age {
        case 0..<3:
            self = .zeroToTwo
        case 3..<9:
            self = .threeToNine
        case 10..<17:
            self = .tenToSeventeen
        case 18..<29:
            self = .eighteenToTwentyNine
        case 30..<59:
            self = .thirtyToFiftyNine
        default:
            self = .sixtyAndOver
        }
    }
}

struct OxfordCoefficients {
    
    static func a(sex: HKBiologicalSex, ageGroup: AgeGroup) -> Double {
        switch sex {
        case .female:
            switch ageGroup {
            case .zeroToTwo:
                return 58.9
            case .threeToNine:
                return 20.1
            case .tenToSeventeen:
                return 11.1
            case .eighteenToTwentyNine:
                return 13.1
            case .thirtyToFiftyNine:
                return 9.74
            case .sixtyAndOver:
                return 10.1
            }
        default:
            switch ageGroup {
            case .zeroToTwo:
                return 61.0
            case .threeToNine:
                return 23.3
            case .tenToSeventeen:
                return 18.4
            case .eighteenToTwentyNine:
                return 16.0
            case .thirtyToFiftyNine:
                return 14.2
            case .sixtyAndOver:
                return 13.5
            }
        }
    }
    
    static func c(sex: HKBiologicalSex, ageGroup: AgeGroup) -> Double {
        switch sex {
        case .female:
            switch ageGroup {
            case .zeroToTwo:
                return -23.1
            case .threeToNine:
                return 507
            case .tenToSeventeen:
                return 761
            case .eighteenToTwentyNine:
                return 558
            case .thirtyToFiftyNine:
                return 694
            case .sixtyAndOver:
                return 569
            }
        default:
            switch ageGroup {
            case .zeroToTwo:
                return -33.7
            case .threeToNine:
                return 514
            case .tenToSeventeen:
                return 581
            case .eighteenToTwentyNine:
                return 545
            case .thirtyToFiftyNine:
                return 593
            case .sixtyAndOver:
                return 514
            }
        }
    }
}

struct SchofieldCoefficients {
    static func a(sex: HKBiologicalSex, ageGroup: AgeGroup) -> Double {
        switch sex {
        case .female:
            switch ageGroup {
            case .zeroToTwo:
                return 58.317
            case .threeToNine:
                return 20.315
            case .tenToSeventeen:
                return 13.384
            case .eighteenToTwentyNine:
                return 14.818
            case .thirtyToFiftyNine:
                return 8.126
            case .sixtyAndOver:
                return 9.082
            }
        default:
            switch ageGroup {
            case .zeroToTwo:
                return 59.512
            case .threeToNine:
                return 22.706
            case .tenToSeventeen:
                return 17.686
            case .eighteenToTwentyNine:
                return 15.057
            case .thirtyToFiftyNine:
                return 11.472
            case .sixtyAndOver:
                return 11.711
            }
        }
    }
    
    static func c(sex: HKBiologicalSex, ageGroup: AgeGroup) -> Double {
        switch sex {
        case .female:
            switch ageGroup {
            case .zeroToTwo:
                return -31.1
            case .threeToNine:
                return 485.9
            case .tenToSeventeen:
                return 692.6
            case .eighteenToTwentyNine:
                return 486.6
            case .thirtyToFiftyNine:
                return 845.6
            case .sixtyAndOver:
                return 658.5
            }
        default:
            switch ageGroup {
            case .zeroToTwo:
                return -30.4
            case .threeToNine:
                return 504.3
            case .tenToSeventeen:
                return 658.2
            case .eighteenToTwentyNine:
                return 692.2
            case .thirtyToFiftyNine:
                return 873.1
            case .sixtyAndOver:
                return 587.7
            }
        }
    }
}
