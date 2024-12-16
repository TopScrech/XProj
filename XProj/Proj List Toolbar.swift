import SwiftUI

struct ProjListToolbar: View {
    @Environment(ProjListVM.self) private var vm
    
    var body: some View {
#if DEBUG
        Menu("Functions") {
            Button("listFilesInFoldersSingleThread") {
                let test = vm.listFilesInFoldersSingleThread(folderPaths: vm.projects.map(\.path))
                print(test)
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
        }
#endif
    }
}
