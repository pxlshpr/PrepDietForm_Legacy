import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes
import HealthKit

struct TDEEForm: View {
    
    @Namespace var namespace
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ViewModel
    
    @FocusState var restingEnergyTextFieldIsFocused: Bool
    
    let didEnterForeground = NotificationCenter.default.publisher(for: .didEnterForeground)
    
    init(userEnergyUnit: EnergyUnit = .kcal, userWeightUnit: WeightUnit = .kg) {
        let viewModel = ViewModel(
            userEnergyUnit: userEnergyUnit,
            userWeightUnit: userWeightUnit
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @ViewBuilder
    var body: some View {
        Group {
            if viewModel.hasAppeared {
                navigationView
            } else {
                Color(.systemGroupedBackground)
                    .onAppear(perform: blankViewAppeared)
            }
        }
        .onReceive(didEnterForeground, perform: didEnterForeground)
        .presentationDetents(viewModel.detents, selection: $viewModel.presentationDetent)
        .presentationDragIndicator(.hidden)
    }

    var navigationView: some View {
        NavigationStack(path: $viewModel.path) {
            form
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Maintenance Calories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { trailingContent }
            .toolbar { leadingContent }
            .onChange(of: viewModel.restingEnergyUsesHealthMeasurements, perform: syncHealthKitMeasurementsChanged)
            .onChange(of: viewModel.restingEnergySource, perform: restingEnergySourceChanged)
            .navigationDestination(for: Route.self, destination: navigationDestination)
            .interactiveDismissDisabled(viewModel.isEditing)
            .task { await initialTask() }
        }
    }
    
    //MARK: - Unsorted
    
    @State var showingAdaptiveCorrectionInfo = false


    @State var applyActivityScaleFactor: Bool = true

    @State var bmrEquation: RestingEnergyFormula = .mifflinStJeor
    @State var activityLevel: ActivityLevel = .moderatelyActive
    @State var biologicalSex: HKBiologicalSex = .male
    @State var weightUnit: WeightUnit = .kg
    @State var heightUnit: HeightUnit = .cm

    @State var manualBMR: Bool = false
    @State var bmrUnit: EnergyUnit = .kcal
    @State var bmrDouble: Double? = nil
    @State var bmrString: String = ""

    @State var manualTDEE: Bool = false
    @State var tdeeUnit: EnergyUnit = .kcal
    @State var tdeeDouble: Double? = nil
    @State var tdeeString: String = ""

    @State var weightDouble: Double? = nil
    @State var weightString: String = ""
    @State var weightDate: Date? = nil

    @State var heightDouble: Double? = nil
    @State var heightString: String = ""
    @State var heightDate: Date? = nil

    @State var heightSecondaryDouble: Double? = nil
    @State var heightSecondaryString: String = ""

    @State var valuesHaveChanged: Bool = true
    
    @State var healthRestingEnergy: Double? = nil
    @State var healthActiveEnergy: Double? = nil
    
    @State var healthEnergyPeriod: HealthPeriodOption = .previousDay
    @State var healthEnergyPeriodInterval: DateComponents = DateComponents(day: 1)
    
//    @State var useHealthAppData = false
}
