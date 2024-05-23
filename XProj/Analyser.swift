import Foundation

extension ProjectListVM {
    func listFilesInFoldersSingleThread(folderPaths: [String]) -> [String: [String]?] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderContents = [String: [String]?]()
        
        for folder in folderPaths {
            let url = URL(fileURLWithPath: folder)
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: url.path)
                folderContents[folder] = files
            } catch {
                folderContents[folder] = nil
            }
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Single-threaded listFilesInFolders completed in \(timeElapsed) seconds")
        
        return folderContents
    }
    
    func countFilesInFoldersSingleThread(folderPaths: [String]) -> [String: Int?] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderFileCounts = [String: Int?]()
        
        for folder in folderPaths {
            let url = URL(fileURLWithPath: folder)
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: url.path)
                folderFileCounts[folder] = files.count
            } catch {
                folderFileCounts[folder] = nil
            }
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Single-threaded countFilesInFolders completed in \(timeElapsed) seconds")
        
        return folderFileCounts
    }
}

extension ProjectListVM {
    func listFilesInFoldersMultiThread(folderPaths: [String], completion: @escaping ([String: [String]?]) -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderContents = [String: [String]?]()
        let dispatchGroup = DispatchGroup()
        
        for folder in folderPaths {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                let url = URL(fileURLWithPath: folder)
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: url.path)
                    DispatchQueue.main.async {
                        folderContents[folder] = files
                        dispatchGroup.leave()
                    }
                } catch {
                    DispatchQueue.main.async {
                        folderContents[folder] = nil
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Multi-threaded listFilesInFolders completed in \(timeElapsed) seconds")
            completion(folderContents)
        }
    }
    
    func countFilesInFoldersMultiThread(folderPaths: [String], completion: @escaping ([String: Int?]) -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderFileCounts = [String: Int?]()
        let dispatchGroup = DispatchGroup()
        
        for folder in folderPaths {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                let url = URL(fileURLWithPath: folder)
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: url.path)
                    DispatchQueue.main.async {
                        folderFileCounts[folder] = files.count
                        dispatchGroup.leave()
                    }
                } catch {
                    DispatchQueue.main.async {
                        folderFileCounts[folder] = nil
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Multi-threaded countFilesInFolders completed in \(timeElapsed) seconds")
            completion(folderFileCounts)
        }
    }
}
