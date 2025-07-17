import SwiftUI

struct ProjListToolbar: View {
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        //        Button("Refresh") {
        //            vm.getFolders()
        //        }
        
#if DEBUG
        Menu("Functions") {
            Button(String("listFilesInFoldersSingleThread")) {
                let test = vm.listFilesInFoldersSingleThread(
                    vm.projects.map(\.path)
                )
                
                print(test)
            }
            
            Button(String("countFilesInFoldersMultiThread")) {
                vm.countFilesInFoldersMultiThread(
                    vm.projects.map(\.path)
                ) { _ in
                    
                }
            }
            
            Button(String("countFilesRecursively")) {
                DispatchQueue.global().async {
                    let start = DispatchTime.now()
                    
                    if let test = vm.countFilesRecursively("/Users/topscrech/Projects") {
                        print(test)
                    }
                    
                    DispatchQueue.main.async {
                        let finish = DispatchTime.now()
                        let timeElapsed = finish.uptimeNanoseconds - start.uptimeNanoseconds
                        let timeElapsedInSeconds = Double(timeElapsed) / 1_000_000_000
                        
                        print("Time elapsed: \(timeElapsedInSeconds)s")
                    }
                }
            }
            
            Button(String("countFilesInFoldersMultiThread")) {
                vm.countFilesInFoldersMultiThread(
                    vm.projects.map(\.path)
                ) { _ in
                    
                }
            }
        }
#endif
    }
}
