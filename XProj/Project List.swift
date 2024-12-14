import SwiftUI

struct ProjectList: View {
    @Environment(ProjectListVM.self) private var vm
    
    @State private var selectedProjects: Set<Project.ID> = []
    
    var body: some View {
        @Bindable var vm = vm
        
        List(selection: $selectedProjects) {
            Section {
                ForEach(vm.filteredProjects) { project in
                    ProjectCard(project, projectsFolder: vm.projectsFolder)
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
            
            ProjectListToolbar()
        }
    }
}

#Preview {
    ProjectList()
        .environment(ProjectListVM())
}
