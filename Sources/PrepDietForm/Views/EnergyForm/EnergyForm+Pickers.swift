import SwiftUI
import SwiftHaptics

extension EnergyForm {
    
    @ViewBuilder
    var typePicker: some View {
        if goal.isForMeal {
            mealTypePicker
        } else {
            dietTypePicker
        }
    }
    
    @ViewBuilder
    var maintenanceButton: some View {
        if shouldShowEnergyDeltaElements {
            Button {
                showingMaintenanceEnergyForm = true
            } label: {
                PickerLabel(
                    "maintenance",
                    systemImage: "gearshape.circle.fill",
                    imageColor: Color(.secondaryLabel),
                    imageScale: .large
                )
            }
        }
    }
    
    var mealTypePicker: some View {
        Menu {
            Picker(selection: $pickedMealEnergyGoalType, label: EmptyView()) {
                ForEach(MealEnergyTypeOption.allCases, id: \.self) {
                    Text($0.description(userEnergyUnit: .kcal)).tag($0)
                }
            }
        } label: {
            PickerLabel(pickedMealEnergyGoalType.description(userEnergyUnit: .kcal))
                .animation(.none, value: pickedMealEnergyGoalType)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded {
            Haptics.feedback(style: .soft)
        })
    }
    
    var dietTypePicker: some View {
        Menu {
            Picker(selection: $pickedDietEnergyGoalType, label: EmptyView()) {
                ForEach(DietEnergyTypeOption.allCases, id: \.self) {
                    Text($0.description(userEnergyUnit: .kcal)).tag($0)
                }
            }
        } label: {
            PickerLabel(pickedDietEnergyGoalType.shortDescription(userEnergyUnit: .kcal))
                .animation(.none, value: pickedDietEnergyGoalType)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded {
            Haptics.feedback(style: .soft)
        })
    }

    @ViewBuilder
    var deltaPicker: some View {
        if shouldShowEnergyDeltaElements {
            HStack {
                Menu {
                    Picker(selection: $pickedDelta, label: EmptyView()) {
                        ForEach(EnergyDeltaOption.allCases, id: \.self) {
                            Text($0.description).tag($0)
                        }
                    }
                } label: {
                    PickerLabel(pickedDelta.description)
                        .animation(.none, value: pickedDelta)
                }
                .contentShape(Rectangle())
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }    
}
