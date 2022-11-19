import Foundation

extension TDEEForm.ViewModel {
    func load(_ profile: BodyProfile) {
        
        let params = profile.parameters
        self.restingEnergySource = params.restingEnergySource
        self.restingEnergyFormula = params.restingEnergyFormula ?? .katchMcardle
        self.restingEnergy = params.restingEnergy
        self.restingEnergyTextFieldString = params.restingEnergy?.cleanAmount ?? ""
        self.restingEnergyPeriod = params.restingEnergyPeriod ?? .average
        self.restingEnergyIntervalValue = params.restingEnergyIntervalValue ?? 1
        self.restingEnergyInterval = params.restingEnergyInterval ?? .week

        self.activeEnergySource = params.activeEnergySource
        self.activeEnergyActivityLevel = params.activeEnergyActivityLevel ?? .moderatelyActive
        self.activeEnergy = params.activeEnergy
        self.activeEnergyTextFieldString = params.activeEnergy?.cleanAmount ?? ""
        self.activeEnergyPeriod = params.activeEnergyPeriod ?? .previousDay
        self.activeEnergyIntervalValue = params.activeEnergyIntervalValue ?? 1
        self.activeEnergyInterval = params.activeEnergyInterval ?? .day

        self.lbmSource = params.lbmSource
        self.lbmFormula = params.lbmFormula ?? .boer
        self.lbmDate = params.lbmDate
        
        if self.lbmSource == .fatPercentage {
            self.lbm = params.fatPercentage
        } else {
            self.lbm = params.lbm
        }
        self.lbmTextFieldString = self.lbm?.cleanAmount ?? ""
        
        self.weightSource = params.weightSource
        self.weight = params.weight
        self.weightTextFieldString = params.weight?.cleanAmount ?? ""
        self.weightDate = params.weightDate

        self.heightSource = params.heightSource
        self.height = params.height
        self.heightTextFieldString = params.height?.cleanAmount ?? ""
        self.heightDate = params.heightDate

        self.sexSource = params.sexSource
        if let sexIsFemale = params.sexIsFemale {
            self.sex = sexIsFemale ? .female : .male
        }

        self.ageSource = params.ageSource
        self.dob = params.dob
        self.age = params.age
        if let age = params.age {
            self.ageTextFieldString = "\(age)"
        }

        //TODO: Revisit this
        self.restingEnergyFetchStatus = .notFetched
        self.activeEnergyFetchStatus = .notFetched
        self.lbmFetchStatus = .notFetched
        self.weightFetchStatus = .notFetched
        self.heightFetchStatus = .notFetched
        self.sexFetchStatus = .notFetched
        self.dobFetchStatus = .notFetched
    }
}
