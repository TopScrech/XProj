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
                }
            }
        }
        .searchable(text: $vm.searchPrompt)
        .searchSuggestions {
            SearchSuggestions()
        }
        .refreshableTask {
            vm.getFolders()
        }
        .toolbar {
            ToolbarItemGroup {
                Button("listFilesInFoldersSingleThread") {
                    let test = vm.listFilesInFoldersSingleThread(folderPaths: vm.projects.map(\.path))
                }
                
                Button("countFilesInFoldersMultiThread") {
                    vm.countFilesInFoldersMultiThread(folderPaths: vm.projects.map(\.path)) { test in
                        print(test)
                    }
                }
                
                Button("countFilesRecursively") {
                    let test = vm.countFilesRecursively("/Users/topscrech/Projects")
                    print(test)
                }
                
                Button("listFilesRecursively") {
                    let test = vm.listFilesRecursively("/Users/topscrech/Projects")
                    print(test)
                }
            }
        }
    }
}

#Preview {
    ProjectList()
        .environment(ProjectListVM())
}
