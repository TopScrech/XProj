import SwiftUI

struct ProjList: View {
    @Environment(ProjListVM.self) private var vm
    
    @State private var selectedProjects: Set<Project.ID> = []
    
    var body: some View {
        @Bindable var vm = vm
        
        List(selection: $selectedProjects) {
            Section {
                ForEach(vm.filteredProjects) { proj in
                    ProjCard(proj)
                }
            } header: {
                HStack {
                    Text("\(vm.projects.count) Projects")
                    
                    Spacer()
                    
                    SmartScan()
                        .environment(vm)
                }
            }
        }
        .searchable(text: $vm.searchPrompt)
        .searchSuggestions {
            SearchSuggestions()
        }
        .refreshableTask {
            vm.getFolders()
            
            //            let duplicates: [()] = vm.findDuplicates().map { duplicates in
            //                print(duplicates.map(\.name))
            //            }
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
            
            ProjListToolbar()
        }
    }
}

#Preview {
    ProjList()
        .environment(ProjListVM())
}
