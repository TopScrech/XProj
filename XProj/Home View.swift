import SwiftUI

struct HomeView: View {
    @Environment(ProjectListVM.self) private var vm
    
    var body: some View {
        ProjectList()
            .toolbar {
                ToolbarItemGroup {
                    Button("Single") {
                        let test = vm.listFilesInFoldersSingleThread(folderPaths: vm.projects.map(\.path))
                    }
                    
                    Button("Multi") {
                        let test = vm.listFilesInFoldersMultiThread(folderPaths: vm.projects.map(\.path)) { test in
                            
                        }
                    }
                }
            }
    }
}

#Preview {
    HomeView()
}
