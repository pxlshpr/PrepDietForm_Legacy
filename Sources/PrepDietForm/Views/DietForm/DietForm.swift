import SwiftUI

public struct DietForm: View {
    
    @StateObject var viewModel = ViewModel()
    @State var showingNutrientsPicker: Bool = false
    
    public init() { }
    
    public var body: some View {
        NavigationView {
            content
            .background(Color(.systemGroupedBackground))
            .navigationTitle($viewModel.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { trailingContent }
            .sheet(isPresented: $showingNutrientsPicker) { nutrientsPicker }
        }
    }
    
    @ViewBuilder
    var content: some View {
        if viewModel.goals.isEmpty {
            emptyContent
        } else {
            scrollView
        }
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.goals, id: \.self) { goal in
                    NavigationLink {
                        goalForm(for: goal)
                    } label: {
                        GoalCell(goal: goal)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    var trailingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if !viewModel.goals.isEmpty {
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

//MARK: - Previews


struct DietForm_Previews: PreviewProvider {
    static var previews: some View {
        DietForm()
    }
}
