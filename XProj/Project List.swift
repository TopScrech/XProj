import SwiftUI

struct ProjectList: View {
    @Environment(ProjectListVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
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
        .onSubmit {
            print("test")
        }
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
            ToolbarItemGroup {
                ProjectListToolbar()
            }
        }
    }
}

#Preview {
    ProjectList()
        .environment(ProjectListVM())
}
