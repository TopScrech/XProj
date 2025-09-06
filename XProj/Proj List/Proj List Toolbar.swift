import ScrechKit

struct ProjListToolbar: View {
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        //        Button("Refresh") {
        //            vm.getFolders()
        //        }
        
#if DEBUG
        Menu("Functions") {
            Button("listFilesInFoldersSingleThread") {
                Task {
                    let _ = await vm.listFilesInFoldersSingleThread(
                        vm.projects.map(\.path)
                    )
                }
            }
            
            Button("countFilesInFoldersMultiThread") {
                Task {
                    await vm.countFilesInFoldersMultiThread(
                        vm.projects.map(\.path)
                    )
                }
            }
            
            Button("countFilesRecursively") {
                Task {
                    let start = DispatchTime.now()
                    
                    if let count = await vm.countFilesRecursively("/Users/topscrech/Projects") {
                        print(count)
                    }
                    
                    let finish = DispatchTime.now()
                    let timeElapsed = finish.uptimeNanoseconds - start.uptimeNanoseconds
                    let timeElapsedInSeconds = Double(timeElapsed) / 1_000_000_000
                    
                    await MainActor.run {
                        print("Time elapsed: \(timeElapsedInSeconds)s")
                    }
                }
            }
        }
#endif
    }
}
