import SwiftUI

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
        .safeAreaInset(edge: .bottom) {
            Text("Projects: \(vm.projectCount) • Swift Packages: \(vm.packageCount) • Vapor: \(vm.vaporCount) • Playgrounds: \(vm.playgroundCount) • Workspaces: \(vm.workspaceCount)")
                .secondary()
                .padding(.vertical, 8)
                .opacity(0)
        }
        .overlay(alignment: .bottom) {
            Text("Projects: \(vm.projectCount) • Swift Packages: \(vm.packageCount) • Vapor: \(vm.vaporCount) • Playgrounds: \(vm.playgroundCount) • Workspaces: \(vm.workspaceCount)")
                .secondary()
                .padding(.vertical, 8)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
        }
        .toolbar {
            Button("Open") {
                vm.openProjects(selectedProjects)
            }
            .opacity(0)
            .keyboardShortcut(.defaultAction)
            .disabled(selectedProjects.isEmpty)
            
            ProjListToolbar()
        }
    }
}

#Preview {
    ProjList([previewProj1, previewProj2])
        .environment(DataModel())
}
