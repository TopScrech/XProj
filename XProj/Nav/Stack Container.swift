import SwiftUI

struct StackContainer: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    
    private let categories = NavCategory.allCases
    
    var body: some View {
        @Bindable var nav = nav
        @Bindable var vm = vm
        
        NavigationStack(path: $nav.projPath) {
            VStack {
                List(categories) { category in
                    Section {
                        ForEach(vm.projects(in: category)) { proj in
                            NavigationLink(value: proj) {
                                ProjCard(proj)
                            }
                        }
                    } header: {
                        Text(category.localizedName)
                    }
                }
                
                BottomBar()
            }
            .navigationTitle("Categories")
            .navigationDestination(for: Proj.self) { proj in
                ProjDetails(proj)
            }
            .toolbar {
                OpenButtons()
            }
        }
        .searchable(text: $vm.searchPrompt)
        .searchSuggestions {
            SearchSuggestions()
        }
    }
}

#Preview {
    StackContainer()
        .environment(DataModel.shared)
        .environment(NavModel.shared)
}
