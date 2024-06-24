import SwiftUI

struct HomeView: View {
    @Environment(ProjectListVM.self) private var vm
    
    var body: some View {
        ProjectList()
            .toolbar {
                ToolbarItemGroup {
                    Button("listFilesInFoldersSingleThread") {
                        let test = vm.listFilesInFoldersSingleThread(folderPaths: vm.projects.map(\.path))
                    }
                    
                    Button("countFilesInFoldersMultiThread") {
                        let test = vm.countFilesInFoldersMultiThread(folderPaths: vm.projects.map(\.path)) { test in
                            
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
    HomeView()
}
