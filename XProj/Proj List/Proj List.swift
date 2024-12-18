import SwiftUI

struct ProjList: View {
    @Environment(ProjListVM.self) private var vm
    
    private let projects: [Project]
    
    init(_ projects: [Project]) {
        self.projects = projects
    }
    
    @State private var selectedProjects: Set<Project.ID> = []
    
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
                .padding(.vertical, 1)
                .opacity(0)
        }
        .overlay(alignment: .bottom) {
            Text("Projects: \(vm.projectCount) • Swift Packages: \(vm.packageCount) • Vapor: \(vm.vaporCount) • Playgrounds: \(vm.playgroundCount) • Workspaces: \(vm.workspaceCount)")
                .secondary()
                .padding(.vertical, 5)
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
        .environment(ProjListVM())
}
