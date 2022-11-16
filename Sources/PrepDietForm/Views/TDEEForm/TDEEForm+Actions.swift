import SwiftUI

let MaximumNumberOfDaysForWeight = 30

extension TDEEForm {
    
    func blankViewAppeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation {
                viewModel.hasAppeared = true
            }
        }
    }
  
    func didEnterForeground(notification: Notification) {
        updateHealthAppData()
    }
    
    func updateHealthAppData() {
        guard viewModel.permissionDeniedForResting else {
            return
        }
        
    }
    
    func syncHealthKitMeasurementsChanged(to syncHealthKitMeasurements: Bool) {
        if syncHealthKitMeasurements {
            Task {
                await fillHealthKitMeasurements()
            }
        } else {
            self.weightDate = nil
        }
    }
    
    func fillHealthKitMeasurements() async {
        guard await HealthKitManager.shared.requestPermission() else {
            print("Couldn't get permission")
            return
        }
        
        await fillHealthKitWeight()
        await fillHealthKitHeight()
        fillHealthKitBiologicalSex()
        fillHealthKitAge()
    }
    
    func fillHealthKitWeight() async {
        guard let (weight, weightDate) = await HealthKitManager.shared.getLatestWeight() else {
            return
        }
        if Date().numberOfDaysFrom(weightDate) > MaximumNumberOfDaysForWeight {
            //TODO: ask user if they would like to old measurement
        }
        await MainActor.run {
            self.weightDouble = weight
            self.weightString = weight.cleanAmount
            self.weightDate = weightDate
        }
    }
    
    func fillHealthKitHeight() async {
        guard let (height, heightDate) = await HealthKitManager.shared.getLatestHeight() else {
            return
        }
        await MainActor.run {
            self.heightDouble = height
            self.heightString = height.cleanAmount
            self.heightDate = heightDate
        }
    }
    
    func fillHealthKitBiologicalSex() {
        self.biologicalSex = HealthKitManager.shared.biologicalSex
    }
    
    func fillHealthKitAge() {
        /// [ ] Get date of birth from health kit
        /// [ ] Calculate age
        /// [ ] Fill it in
    }
}
