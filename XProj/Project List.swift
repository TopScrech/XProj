import SwiftUI

struct ProjectList: View {
    @Environment(ProjectListVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                ForEach(vm.filteredProjects) { project in
                    ProjectCard(project)
                }
            } header: {
                HStack {
                    Spacer()
                    
                    Text("\(vm.projects.count) Projects")
                    
                    let count = vm.findDuplicates().reduce(0) {
                        $0 + $1.count
                    }
                    
                    Text("(\(count) duplicates)")
                        .foregroundStyle(.tertiary)
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
#if DEBUG
        .toolbar {
            ToolbarItemGroup {
                ProjectListToolbar()
            }
        }
#endif
    }
}

#Preview {
    ProjectList()
        .environment(ProjectListVM())
}
