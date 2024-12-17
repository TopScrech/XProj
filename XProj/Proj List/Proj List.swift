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
        .safeAreaInset(edge: .bottom) {
            Text("Projects: \(vm.projectCount) • Swift Packages: \(vm.packageCount) • Playgrounds: \(vm.playgroundCount)")
                .footnote()
                .secondary()
                .padding(.vertical, 1)
                .opacity(0)
        }
        .overlay(alignment: .bottom) {
            Text("Projects: \(vm.projectCount) • Swift Packages: \(vm.packageCount) • Playgrounds: \(vm.playgroundCount)")
                .footnote()
                .secondary()
                .padding(.vertical, 5)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
        }
        .searchSuggestions {
            SearchSuggestions()
        }
        //        .refreshableTask {
        //            vm.getFolders()
        //
        //            let duplicates: [()] = vm.findDuplicates().map { duplicates in
        //                print(duplicates.map(\.name))
        //            }
        //        }
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
            
            ProjListToolbar()
        }
    }
}

//#Preview {
//    ProjList()
//        .environment(ProjListVM())
//}
