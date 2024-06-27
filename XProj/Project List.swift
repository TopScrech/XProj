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
                Menu {
                    Button("listFilesInFoldersSingleThread") {
                        let test = vm.listFilesInFoldersSingleThread(folderPaths: vm.projects.map(\.path))
                    }
                    
                    Button("countFilesInFoldersMultiThread") {
                        vm.countFilesInFoldersMultiThread(folderPaths: vm.projects.map(\.path)) { _ in
                            
                        }
                    }
                    
                    Button("countFilesRecursively") {
                        DispatchQueue.global().async {
                            let start = DispatchTime.now()
                            
                            let test = vm.countFilesRecursively("/Users/topscrech/Projects")
                            print(test)
                            
                            DispatchQueue.main.async {
                                let finish = DispatchTime.now()
                                let timeElapsed = finish.uptimeNanoseconds - start.uptimeNanoseconds
                                let timeElapsedInSeconds = Double(timeElapsed) / 1_000_000_000
                                
                                print("Time elapsed: \(timeElapsedInSeconds) seconds")
                            }
                        }
                    }
                    
                    Button("countFilesInFoldersMultiThread") {
                        vm.countFilesInFoldersMultiThread(folderPaths: vm.projects.map(\.path)) { _ in
                            
                        }
                    }
                } label: {
                    Text("Functions")
                }
            }
        }
#endif
    }
}

#Preview {
    ProjectList()
        .environment(ProjectListVM())
}
