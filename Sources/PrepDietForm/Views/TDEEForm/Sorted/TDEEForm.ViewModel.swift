import SwiftUI
import PrepDataTypes
import SwiftHaptics
import HealthKit

extension HeightUnit {
    var cm: Double {
        switch self {
        case .cm:
            return 1
        case .ft:
            return 30.48
        case .m:
            return 100
        }
    }
    
    var healthKitUnit: HKUnit {
        switch self {
        case .cm:
            return .meterUnit(with: .centi)
        case .ft:
            return .foot()
        case .m:
            return .meter()
        }
    }
}

extension TDEEForm.ViewModel {
    var restingEnergyFormatted: String {
        guard let restingEnergy else {
            return ""
        }
        return restingEnergy.formattedEnergy
    }

    var notSetup: Bool {
        true
    }
    
    var detents: Set<PresentationDetent> {
        notSetup ? [.height(270), .large] : [.medium, .large]
    }
    
    var maintenanceEnergy: Double? {
        nil
    }
    
    var hasRestingEnergy: Bool {
        restingEnergy != nil
    }

    var hasDynamicRestingEnergy: Bool {
        restingEnergySource == .healthApp
        || (restingEnergySource == .formula && restingEnergyUsesHealthMeasurements)
    }
}

//MARK: - Biological Sex
extension TDEEForm.ViewModel {
    var sexSourceBinding: Binding<MeasurementSourceOption> {
        Binding<MeasurementSourceOption>(
            get: { self.sexSource ?? .userEntered },
            set: { newSource in
                Haptics.feedback(style: .soft)
                self.changeSexSource(to: newSource)
            }
        )
    }
    
    var sexPickerBinding: Binding<HKBiologicalSex> {
        Binding<HKBiologicalSex>(
            get: { self.sex ?? .male },
            set: { newSex in
                Haptics.feedback(style: .soft)
                withAnimation {
                    self.sex = newSex
                }
            }
        )
    }
    
    func changeSexSource(to newSource: MeasurementSourceOption) {
        withAnimation {
            sexSource = newSource
        }
        if newSource == .healthApp {
            fetchSexFromHealth()
        }
    }
    
    func fetchSexFromHealth() {
        withAnimation {
            sexFetchStatus = .fetching
        }
        
        Task {
            guard let sex = await HealthKitManager.shared.currentBiologicalSex() else {
                return
            }
            await MainActor.run {
                withAnimation {
                    self.sexFetchStatus = .fetched
                    self.sex = sex
                }
            }
        }
    }
    
    var sexFormatted: String {
        switch sex {
        case .male:
            return "male"
        case .female:
            return "female"
        default:
            return ""
        }
    }
    var hasSex: Bool {
        sex != nil
    }
    
    var hasDynamicSex: Bool {
        sexSource == .healthApp
    }
}

//MARK: - Height
extension TDEEForm.ViewModel {
    var heightSourceBinding: Binding<MeasurementSourceOption> {
        Binding<MeasurementSourceOption>(
            get: { self.heightSource ?? .userEntered },
            set: { newSource in
                Haptics.feedback(style: .soft)
                self.changeHeightSource(to: newSource)
            }
        )
    }
    
    func changeHeightSource(to newSource: MeasurementSourceOption) {
        withAnimation {
            heightSource = newSource
        }
        if newSource == .healthApp {
            fetchHeightFromHealth()
        }
    }
    
    var heightInCm: Double? {
        guard let height else { return nil }
        return userHeightUnit.cm * height
    }
    
    var heightTextFieldStringBinding: Binding<String> {
        Binding<String>(
            get: { self.heightTextFieldString },
            set: { newValue in
                guard !newValue.isEmpty else {
                    self.height = nil
                    self.heightTextFieldString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.height = double
                withAnimation {
                    self.heightTextFieldString = newValue
                }
            }
        )
    }
    
    func fetchHeightFromHealth() {
        withAnimation {
            heightFetchStatus = .fetching
        }
        
        Task {
            guard let (height, date) = await HealthKitManager.shared.latestHeight(unit: userHeightUnit) else {
                return
            }
            await MainActor.run {
                withAnimation {
                    self.heightFetchStatus = .fetched
                    self.height = height
                    self.heightTextFieldString = height.cleanAmount
                    self.heightDate = date
                }
            }
        }
    }
    
    var heightFormatted: String {
        height?.cleanAmount ?? ""
    }

    var heightFormattedWithUnit: String {
        guard let height else { return "" }
        return height.cleanAmount + " " + userHeightUnit.shortDescription
    }

    var hasHeight: Bool {
        height != nil
    }
    
    var hasDynamicHeight: Bool {
        heightSource == .healthApp
    }
}

//MARK: - Weight
extension TDEEForm.ViewModel {
    var weightSourceBinding: Binding<MeasurementSourceOption> {
        Binding<MeasurementSourceOption>(
            get: { self.weightSource ?? .userEntered },
            set: { newSource in
                Haptics.feedback(style: .soft)
                self.changeWeightSource(to: newSource)
            }
        )
    }
    
    func changeWeightSource(to newSource: MeasurementSourceOption) {
        withAnimation {
            weightSource = newSource
        }
        if newSource == .healthApp {
            fetchWeightFromHealth()
        }
    }
    
    var weightInKg: Double? {
        guard let weight else { return nil }
        switch userWeightUnit {
        case .kg:
            return weight
        case .lb:
            return (WeightUnit.lb.g/WeightUnit.kg.g) * weight
        default:
            return nil
        }
    }
    
    var weightTextFieldStringBinding: Binding<String> {
        Binding<String>(
            get: { self.weightTextFieldString },
            set: { newValue in
                guard !newValue.isEmpty else {
                    self.weight = nil
                    self.weightTextFieldString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.weight = double
                withAnimation {
                    self.weightTextFieldString = newValue
                }
            }
        )
    }
    
    func fetchWeightFromHealth() {
        withAnimation {
            weightFetchStatus = .fetching
        }
        
        Task {
            guard let (weight, date) = await HealthKitManager.shared.latestWeight(unit: userWeightUnit) else {
                return
            }
            await MainActor.run {
                withAnimation {
                    self.weightFetchStatus = .fetched
                    self.weight = weight
                    self.weightTextFieldString = weight.cleanAmount
                    self.weightDate = date
                }
            }
        }
    }
    
    var weightFormatted: String {
        weight?.cleanAmount ?? ""
    }

    var weightFormattedWithUnit: String {
        guard let weight else { return "" }
        return weight.cleanAmount + " " + userWeightUnit.shortDescription
    }

    var hasWeight: Bool {
        weight != nil
    }
    
    var hasDynamicWeight: Bool {
        weightSource == .healthApp
    }
}

//MARK: - LBM
extension TDEEForm.ViewModel {
    var lbmSourceBinding: Binding<LeanBodyMassSourceOption> {
        Binding<LeanBodyMassSourceOption>(
            get: { self.lbmSource ?? .userEntered },
            set: { newSource in
                Haptics.feedback(style: .soft)
                self.changeLBMSource(to: newSource)
            }
        )
    }
    
    func changeLBMSource(to newSource: LeanBodyMassSourceOption) {
        withAnimation {
            lbmSource = newSource
        }
        if newSource == .healthApp {
            Task {
                await fetchLBMFromHealth()
                await MainActor.run {
                    withAnimation {
                        calculateRestingEnergy()
                    }
                }
            }
        }
    }
    
    var lbmInKg: Double? {
        guard let lbm else { return nil }
        switch userWeightUnit {
        case .kg:
            return lbm
        case .lb:
            return (WeightUnit.lb.g/WeightUnit.kg.g) * lbm
        default:
            return nil
        }
    }
    
    var lbmTextFieldStringBinding: Binding<String> {
        Binding<String>(
            get: { self.lbmTextFieldString },
            set: { newValue in
                guard !newValue.isEmpty else {
                    self.lbm = nil
                    self.lbmTextFieldString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.lbm = double
                withAnimation {
                    self.lbmTextFieldString = newValue
                }
            }
        )
    }
    
    var lbmFormulaBinding: Binding<LeanBodyMassFormula> {
        Binding<LeanBodyMassFormula>(
            get: { self.lbmFormula },
            set: { newFormula in
                Haptics.feedback(style: .soft)
                self.changeLBMFormula(to: newFormula)
            }
        )
    }
    
    func changeLBMFormula(to newFormula: LeanBodyMassFormula) {
        withAnimation {
            self.lbmFormula = newFormula
        }
    }
    
    func fetchLBMFromHealth() async {
        await MainActor.run {
            withAnimation {
                lbmFetchStatus = .fetching
            }
        }
        
        guard let (lbm, date) = await HealthKitManager.shared.latestLeanBodyMass(unit: userWeightUnit) else {
            return
        }
        await MainActor.run {
            withAnimation {
                self.lbmFetchStatus = .fetched
                self.lbm = lbm
                self.lbmTextFieldString = lbm.cleanAmount
                self.lbmDate = date
            }
        }
    }
    
    var lbmFormatted: String {
        lbm?.cleanAmount ?? ""
    }
    
    var calculatedLBMFormatted: String {
        calculatedLeanBodyMass?.cleanAmount ?? "empty"
    }

    var lbmFormattedWithUnit: String {
        let value: Double?
        switch lbmSource {
        case .formula, .fatPercentage:
            value = calculatedLeanBodyMass
        default:
            value = lbm
        }
        guard let value else { return "" }
        return value.cleanAmount + " " + userWeightUnit.shortDescription
    }

    var hasLeanBodyMass: Bool {
        switch lbmSource {
        case .fatPercentage:
            return calculatedLeanBodyMass != nil
        case .formula:
            //TODO: check if we have a height and weight
            return false
        case .healthApp, .userEntered:
            return lbm != nil
        default:
            return false
        }
    }
    
    var calculatedLeanBodyMass: Double? {
        switch lbmSource {
        case .fatPercentage:
            guard let percent = lbm, let weight else { return nil }
            guard percent >= 0, percent <= 100 else { return nil }
            return (1.0 - (percent/100.0)) * weight
        case .formula:
            
            //TODO: Calculate it here
            return nil
        default:
            return nil
        }
    }
    
    var hasDynamicLeanBodyMass: Bool {
        lbmSource == .healthApp
        || (lbmSource == .formula && lbmUsesHealthMeasurements)
    }
}

//MARK: - Resting Energy

extension TDEEForm.ViewModel {
    
    var restingEnergyIntervalValues: [Int] {
        Array(restingEnergyInterval.minValue...restingEnergyInterval.maxValue)
    }

    func calculateRestingEnergy() {
        guard restingEnergySource == .formula else {
            return
        }
        switch restingEnergyFormula {
        case .katchMcardle:
            guard let lbmInKg else {
                self.restingEnergy = nil
                return
            }
            var energy = 370 + (21.6 * lbmInKg)
            if userEnergyUnit == .kJ {
                energy = energy * KcalsPerKilojule
            }
            withAnimation {
                self.restingEnergy = energy
                self.restingEnergyTextFieldString = "\(Int(energy.rounded()))"
            }
        default:
            break
        }
    }
    
    var restingEnergySourceBinding: Binding<RestingEnergySourceOption> {
        Binding<RestingEnergySourceOption>(
            get: { self.restingEnergySource ?? .userEntered },
            set: { newSource in
                Haptics.feedback(style: .soft)
                self.changeRestingEnergySource(to: newSource)
            }
        )
    }
    
    var restingEnergyTextFieldStringBinding: Binding<String> {
        Binding<String>(
            get: { self.restingEnergyTextFieldString },
            set: { newValue in
                guard !newValue.isEmpty else {
                    self.restingEnergy = nil
                    self.restingEnergyTextFieldString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.restingEnergy = double
                withAnimation {
                    self.restingEnergyTextFieldString = newValue
                }
            }
        )
    }
    
    func changeRestingEnergySource(to newSource: RestingEnergySourceOption) {
        withAnimation {
            restingEnergySource = newSource
        }
        switch restingEnergySource {
        case .healthApp:
            fetchRestingEnergyFromHealth()
        case .formula:
            calculateRestingEnergy()
        default:
            break
        }
    }
    
    var restingEnergyFormulaBinding: Binding<RestingEnergyFormula> {
        Binding<RestingEnergyFormula>(
            get: { self.restingEnergyFormula },
            set: { newFormula in
                Haptics.feedback(style: .soft)
                self.changeRestingEnergyFormula(to: newFormula)
            }
        )
    }

    func changeRestingEnergyFormula(to newFormula: RestingEnergyFormula) {
        withAnimation {
            self.restingEnergyFormula = newFormula
        }
    }
    
    var restingEnergyPeriodBinding: Binding<HealthPeriodOption> {
        Binding<HealthPeriodOption>(
            get: { self.restingEnergyPeriod },
            set: { newPeriod in
                Haptics.feedback(style: .soft)
                self.changeRestingEnergyPeriod(to: newPeriod)
            }
        )
    }

    func changeRestingEnergyPeriod(to newPeriod: HealthPeriodOption) {
        withAnimation {
            self.restingEnergyPeriod = newPeriod
            if newPeriod == .previousDay {
                restingEnergyIntervalValue = 1
                restingEnergyInterval = .day
            } else {
                correctRestingEnergyIntervalValueIfNeeded()
            }
        }
        fetchRestingEnergyFromHealth()
    }
    
    var restingEnergyIntervalValueBinding: Binding<Int> {
        Binding<Int>(
            get: { self.restingEnergyIntervalValue },
            set: { newValue in
                Haptics.feedback(style: .soft)
                self.changeRestingEnergyIntervalValue(to: newValue)
            }
        )
    }
    
    func changeRestingEnergyIntervalValue(to newValue: Int) {
        guard newValue >= restingEnergyInterval.minValue,
              newValue <= restingEnergyInterval.maxValue else {
            return
        }
        withAnimation {
            restingEnergyIntervalValue = newValue
        }
        fetchRestingEnergyFromHealth()
    }
    
    var restingEnergyIntervalBinding: Binding<HealthAppInterval> {
        Binding<HealthAppInterval>(
            get: { self.restingEnergyInterval },
            set: { newInterval in
                Haptics.feedback(style: .soft)
                self.changeRestingEnergyInterval(to: newInterval)
            }
        )
    }
    
    func changeRestingEnergyInterval(to newInterval: HealthAppInterval) {
        withAnimation {
            restingEnergyInterval = newInterval
            correctRestingEnergyIntervalValueIfNeeded()
        }
        
        fetchRestingEnergyFromHealth()
    }
    
    func correctRestingEnergyIntervalValueIfNeeded() {
        if restingEnergyIntervalValue < restingEnergyInterval.minValue {
            restingEnergyIntervalValue = restingEnergyInterval.minValue
        }
        if restingEnergyIntervalValue > restingEnergyInterval.maxValue {
            restingEnergyIntervalValue = restingEnergyInterval.maxValue
        }
    }

    var maintenanceEnergyFooterText: Text {
        let energy = userEnergyUnit == .kcal ? "calories" : "kiljoules"
        return Text("This is an estimate of how many \(energy) you would have to consume to *maintain* your current weight.")
    }
    
    var restingEnergyFooterString: String? {
        let prefix = "This is an estimate of the energy your body uses each day while minimally active."
        if restingEnergySource == .healthApp {
            return prefix + " This will sync with your Health data and update daily."
        }
        return prefix
    }
    
    func updateHealthAppDataIfNeeded() {
        if restingEnergySource == .healthApp {
            fetchRestingEnergyFromHealth()
        }
        //TODO: If its formula, fetch any measurements we have received new permissions for
    }

    func fetchRestingEnergyFromHealth() {
        withAnimation {
            restingEnergyFetchStatus = .fetching
        }
        
        Task {
            do {
                guard let average = try await HealthKitManager.shared.averageSumOfRestingEnergy(
                    using: userEnergyUnit,
                    overPast: restingEnergyIntervalValue,
                    interval: restingEnergyInterval
                ) else {
                    restingEnergyFetchStatus = .notAuthorized
                    return
                }
                await MainActor.run {
                    withAnimation {
                        print("🔥 setting average: \(average)")
                        restingEnergy = average
                        restingEnergyTextFieldString = "\(Int(average.rounded()))"
                        restingEnergyFetchStatus = .fetched
                    }
                }
            } catch HealthKitManagerError.couldNotGetSumQuantity {
                /// Indicates that permissions are not present
                await MainActor.run {
                    withAnimation {
                        restingEnergyFetchStatus = .notAuthorized
                    }
                }
            } catch {
                
            }
            /// [ ] Make sure we persist this to the backend once the user saves it
        }
    }
}
