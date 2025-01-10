import SwiftUI

#warning("Unused, move out all stuff")
struct ProjList: View {
    @Environment(DataModel.self) private var vm
    
    private let projects: [Proj]
    
    init(_ projects: [Proj]) {
        self.projects = projects
    }
    
    @State private var selectedProjects: Set<Proj> = []
    
    var body: some View {
        @Bindable var vm = vm
        
        List(projects, selection: $selectedProjects) { proj in
            ProjCard(proj)
        }
        .searchable(text: $vm.searchPrompt)
        .searchSuggestions {
            SearchSuggestions()
        }
    }
}

#Preview {
    ProjList([previewProj1, previewProj2])
        .environment(DataModel.shared)
}
