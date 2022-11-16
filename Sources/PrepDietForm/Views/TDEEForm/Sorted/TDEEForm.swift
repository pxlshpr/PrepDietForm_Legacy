import SwiftUI
import SwiftUISugar
import SwiftHaptics
import PrepDataTypes
import HealthKit

extension TDEEForm.ViewModel {
    var notSetup: Bool {
        true
    }
    
    var detents: Set<PresentationDetent> {
        notSetup ? [.height(270), .large] : [.medium, .large]
    }
    
    var maintenanceEnergy: Double? {
        nil
    }
}

struct TDEEForm: View {
    
    @Namespace var namespace
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = ViewModel()
    
    let userEnergyUnit: EnergyUnit
    let didEnterForeground = NotificationCenter.default.publisher(for: .didEnterForeground)
    
    init(userEnergyUnit: EnergyUnit = .kcal) {
        self.userEnergyUnit = userEnergyUnit
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
        NavigationStack(path: $path) {
            form
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Maintenance Calories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { trailingContent }
            .toolbar { leadingContent }
            .onChange(of: syncHealthKitMeasurements, perform: syncHealthKitMeasurementsChanged)
            .navigationDestination(for: Route.self, destination: navigationDestination)
            .interactiveDismissDisabled(viewModel.isEditing)
            .task { await initialTask() }
        }
    }
    
    //MARK: - Unsorted
    
    @State var showingAdaptiveCorrectionInfo = false

    @State var restingEnergySource: RestingEnergySourceOption = .healthApp
    @State var activeEnergySource: ActiveEnergySourceOption = .healthApp

    @State var syncHealthKitMeasurements: Bool = false
    @State var applyActivityScaleFactor: Bool = true

    @State var bmrEquation: TDEEFormula = .mifflinStJeor
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
    
    @State var healthEnergyPeriod: HealthKitEnergyPeriodOption = .previousDay
    @State var healthEnergyPeriodInterval: DateComponents = DateComponents(day: 1)
    
    @State var path: [Route] = []
    @State var useHealthAppData = false
}
