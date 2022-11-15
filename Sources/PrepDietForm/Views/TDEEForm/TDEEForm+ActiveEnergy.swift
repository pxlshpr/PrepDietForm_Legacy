import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes

import Foundation

struct FatPercentageForm: View {
    var body: some View {
        Text("Fat percenteage form")
    }
}

struct HeightForm: View {
    var body: some View {
        Text("Height form")
    }
}

struct WeightForm: View {
    var body: some View {
        Text("Weight form")
    }
}

struct HealthAppPeriodPicker: View {
    
    enum Interval: CaseIterable {
        case day
        case week
        case month
        
        var description: String {
            switch self {
            case .day:
                return "day"
            case .week:
                return "week"
            case .month:
                return "month"
            }
        }
        
        var minQuantity: Int {
            switch self {
            case .day:
                return 2
            default:
                return 1
            }
        }
        var maxQuantity: Int {
            switch self {
            case .day:
                return 6
            case .week:
                return 3
            case .month:
                return 12
            }
        }
    }
    
    @State var selection: Int = 1
    
    @State var quantity: Int = 1
    @State var interval: Interval = .week
    
    var typePicker: some View {
        let selectionBinding = Binding<Int>(
            get: { selection },
            set: { newValue in
                withAnimation {
                    Haptics.feedback(style: .soft)
                    selection = newValue
                }
            }
        )
        
        return Picker("", selection: selectionBinding) {
            Text("From Previous Day").tag(0)
            Text("Average").tag(1)
        }
        .pickerStyle(.segmented)
    }
    
    var body: some View {
        FormStyledScrollView {
            FormStyledSection {
                VStack(spacing: 20) {
                    typePicker
                    if selection == 1 {
                        HStack {
                            Menu {
                                Picker(selection: $quantity, label: EmptyView()) {
                                    ForEach(Array(interval.minQuantity...interval.maxQuantity), id: \.self) { quantity in
                                        Text("\(quantity)").tag(quantity)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("\(quantity)")
                                    Image(systemName: "chevron.up.chevron.down")
                                        .imageScale(.small)
                                }
                            }
                            Menu {
                                Picker(selection: $interval, label: EmptyView()) {
                                    ForEach(Interval.allCases, id: \.self) { interval in
                                        Text("\(interval.description)\(quantity > 1 ? "s" : "")").tag(interval)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("\(interval.description)\(quantity > 1 ? "s" : "")")
                                    Image(systemName: "chevron.up.chevron.down")
                                        .imageScale(.small)
                                }
                            }
                        }
                    }
                }
            }
        }
//        .navigationTitle("Active Energy")
        .toolbar { principalContent }
    }
    
    var principalContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack {
                appleHealthSymbol
                Text("Health App")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

extension TDEEForm {
    
    @ViewBuilder
    func navigationDestination(for route: Route) -> some View {
        switch route {
        case .healthAppPeriod:
            HealthAppPeriodPicker()
        case .fatPercentageForm:
            FatPercentageForm()
        case .heightForm:
            HeightForm()
        case .weightForm:
            WeightForm()
        }
    }
    
    var activeEnergyHealthAppPeriodLink: some View {
        Button {
            path.append(.healthAppPeriod)
        } label: {
            HStack(spacing: 5) {
                Text("Average of past 2 weeks")
                    .multilineTextAlignment(.leading)
//                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
//                    .foregroundColor(Color(.tertiaryLabel))
                    .fontWeight(.semibold)
                    .imageScale(.small)
            }
            .foregroundColor(.accentColor)
        }
        .buttonStyle(.borderless)
    }
    
    var activeEnergySection: some View {
        var header: some View {
            Text("Active Energy")
        }
        
        var footer: some View {
            var string: String {
                if activeEnergySource == .healthApp {
                    return "Your active energy will be what you burned the day before. This will update daily."
                } else if activeEnergySource == .activityLevel {
                    if activityLevel == .notSet {
                        return ""
//                        return "Your maintenance energy equals your resting energy as no activity level is set."
                    } else {
                        return "A scale factor of \(activityLevel.scaleFactor.cleanAmount)× is being applied to your resting energy to calculate this."
                    }
                } else {
                    return ""
                }
            }
            return Group {
                if !string.isEmpty {
                    Text(string)
                }
            }
        }

        
        var calculatedActiveEnergyField: some View {
            HStack {
                if activeEnergySource == .activityLevel {
                    activityLevelPicker
                } else {
                    activeEnergyHealthAppPeriodLink
//                        .background(Color.blue)
                }
                Spacer()
                Group {
                    if isSwiftUIPreview {
                        Text("1,228")
                    } else {
                        if let healthActiveEnergy {
                            Text(healthActiveEnergy.formattedEnergy)
                        }
                    }
                }
                .monospacedDigit()
                .foregroundColor(.secondary)
                Text("kcal")
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }

        var activityLevelPicker: some View {
            Menu {
                Picker(selection: $activityLevel, label: EmptyView()) {
                    ForEach(ActivityLevel.allCases, id: \.self) {
                        Text($0.description).tag($0)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(activityLevel.description)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.accentColor)
                .animation(.none, value: activityLevel)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.feedback(style: .soft)
            })
        }
        
        var activityLevelField: some View {
            HStack {
                Text("Activity Level")
                Spacer()
                activityLevelPicker
            }
        }
        
        var sourceField: some View {
            var picker: some View {
                let tdeeSourceBinding = Binding<ActiveEnergySourceOption>(
                    get: { activeEnergySource },
                    set: { newValue in
                        Haptics.feedback(style: .soft)
                        withAnimation {
                            activeEnergySource = newValue
                        }
                    }
                )
                
                return Menu {
                    Picker(selection: tdeeSourceBinding, label: EmptyView()) {
                        ForEach(ActiveEnergySourceOption.allCases, id: \.self) {
                            Label($0.menuDescription, systemImage: $0.systemImage).tag($0)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        HStack {
                            if activeEnergySource == .healthApp {
                                appleHealthSymbol
                            }
                            Text(activeEnergySource.pickerDescription)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundColor(.accentColor)
                    .animation(.none, value: activeEnergySource)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
            }
            return HStack {
                Text("Source")
                Spacer()
                picker
            }
        }

        var textField: some View {
            var unitPicker: some View {
                Menu {
                    Picker(selection: $bmrUnit, label: EmptyView()) {
                        ForEach(EnergyUnit.allCases, id: \.self) {
                            Text($0.shortDescription).tag($0)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(bmrUnit.shortDescription)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: true, vertical: true)
                    .animation(.none, value: bmrUnit)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.feedback(style: .soft)
                })
            }
            
            let bmrBinding = Binding<String>(
                get: {
                    bmrString
                },
                set: { newValue in
                    guard !newValue.isEmpty else {
                        bmrDouble = nil
                        bmrString = newValue
                        return
                    }
                    guard let double = Double(newValue) else {
                        return
                    }
                    bmrDouble = double
                    withAnimation {
                        bmrString = newValue
                    }
                }
            )
            
            var textField: some View {
                TextField("Resting Energy in", text: bmrBinding)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            
            return HStack {
                Text("Resting Energy")
                Spacer()
                textField
                unitPicker
            }
        }
        
        
        return Section(header: header, footer: footer) {
            sourceField
            switch activeEnergySource {
            case .healthApp:
//                activeEnergyHealthAppPeriodLink
                calculatedActiveEnergyField
            case .activityLevel:
//                activityLevelField
                calculatedActiveEnergyField
            case .userEntered:
                textField
            }
        }
    }
}

func formToggleBinding(_ binding: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { binding.wrappedValue },
        set: { newValue in
            Haptics.feedback(style: .soft)
            withAnimation(.interactiveSpring()) {
                binding.wrappedValue = newValue
            }
        }
    )
}
