import PrepDataTypes

extension Macro {
    
    func grams(equallingPercent percent: Double, of energy: Double) -> Double {
        guard percent >= 0, percent <= 100, energy > 0 else { return 0 }
        let energyPortion = energy * (percent / 100)
        return energyPortion / kcalsPerGram
    }
    
    var kcalsPerGram: Double {
        switch self {
        case .carb:
            return KcalsPerGramOfCarb
        case .fat:
            return KcalsPerGramOfFat
        case .protein:
            return KcalsPerGramOfProtein
        }
    }
}
