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
        
        List(selection: $selectedProjects) {
            ForEach(projects) { proj in
                ProjCard(proj)
            }
        }
        .searchable(text: $vm.searchPrompt)
        .searchSuggestions {
            SearchSuggestions()
        }
        .task {
            if let firstProject = projects.first {
                selectedProjects = [firstProject.id]
            }
        }
        .safeAreaInset(edge: .bottom) {
            Text("Projects: \(vm.projectCount) • Swift Packages: \(vm.packageCount) • Vapor: \(vm.vaporCount) • Playgrounds: \(vm.playgroundCount) • Workspaces: \(vm.workspaceCount)")
//                .footnote()
                .secondary()
                .padding(.vertical, 1)
                .opacity(0)
        }
        .overlay(alignment: .bottom) {
            Text("Projects: \(vm.projectCount) • Swift Packages: \(vm.packageCount) • Vapor: \(vm.vaporCount) • Playgrounds: \(vm.playgroundCount) • Workspaces: \(vm.workspaceCount)")
//                .footnote()
                .secondary()
                .padding(.vertical, 5)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
        }
        .toolbar {
            Button("Open") {
                let selected = vm.projects.filter {
                    selectedProjects.contains($0.id)
                }
                
                let paths = selected.map(\.path)
                
                vm.openProjects(paths)
            }
            .opacity(0)
            .keyboardShortcut(.defaultAction)
            .disabled(selectedProjects.isEmpty)
            
            Button("Refresh") {
                vm.getFolders()
            }
            
            ProjListToolbar()
        }
    }
}

#Preview {
    ProjList([previewProj1, previewProj2])
        .environment(ProjListVM())
}
