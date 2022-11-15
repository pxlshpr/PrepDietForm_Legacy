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
