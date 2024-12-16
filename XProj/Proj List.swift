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
            Section("\(projects.count) Projects") {
                ForEach(projects) { proj in
                    ProjCard(proj)
                }
            }
        }
        .searchable(text: $vm.searchPrompt)
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
