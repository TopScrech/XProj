import Foundation

extension DataModel {
    func listFilesInFoldersSingleThread(_ folderPaths: [String]) -> [String: [String]?] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderContents = [String: [String]?]()
        var totalFiles = 0
        
        for folder in folderPaths {
            if let files = listFilesRecursively(folder) {
                folderContents[folder] = files
                totalFiles += files.count
            } else {
                folderContents[folder] = nil
            }
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        print(String(format: "Single-threaded scanned", folderContents.count, "folders in %.3f seconds", timeElapsed))
        print("Total files found:", totalFiles)
        
        return folderContents
    }
    
    func countFilesInFoldersSingleThread(_ folderPaths: [String]) -> [String: Int?] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderFileCounts = [String: Int?]()
        var totalFiles = 0
        
        for folder in folderPaths {
            if let count = countFilesRecursively(folder) {
                folderFileCounts[folder] = count
                totalFiles += count
            } else {
                folderFileCounts[folder] = nil
            }
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print(String(format: "Single-threaded scanned", folderFileCounts.count, "folders in %.3f seconds", timeElapsed))
        print("Total files found:", totalFiles)
        
        return folderFileCounts
    }
    
    func countFilesRecursively(_ folder: String) -> Int? {
        var fileCount = 0
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folder)
            
            for item in contents {
                let fullPath = (folder as NSString)
                    .appendingPathComponent(item)
                
                var isDirectory: ObjCBool = false
                
                let isExisting = FileManager.default.fileExists(
                    atPath: fullPath,
                    isDirectory: &isDirectory
                )
                
                guard isExisting else {
                    return nil
                }
                
                if isDirectory.boolValue {
                    if let nestedCount = countFilesRecursively(fullPath) {
                        fileCount += nestedCount
                    }
                } else {
                    fileCount += 1
                }
            }
        } catch {
            return nil
        }
        
        return fileCount
    }
}

extension DataModel {
    func listFilesRecursively(_ folder: String) -> [String]? {
        var allFiles = [String]()
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folder)
            
            for item in contents {
                let fullPath = (folder as NSString)
                    .appendingPathComponent(item)
                
                var isDirectory: ObjCBool = false
                
                let isExisting = FileManager.default.fileExists(
                    atPath: fullPath,
                    isDirectory: &isDirectory
                )
                
                guard isExisting else {
                    return nil
                }
                
                if isDirectory.boolValue {
                    if let nestedFiles = listFilesRecursively(fullPath) {
                        allFiles.append(contentsOf: nestedFiles)
                    }
                } else {
                    allFiles.append(fullPath)
                }
            }
        } catch {
            return nil
        }
        
        return allFiles
    }
    
    func countFilesInFoldersMultiThread(
        _ folderPaths: [String],
        completion: @escaping ([String: Int?]) -> Void
    ) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderFileCounts = [String: Int?]()
        let dispatchGroup = DispatchGroup()
        let lock = NSLock()
        var totalFiles = 0
        
        for folder in folderPaths {
            dispatchGroup.enter()
            
            DispatchQueue.global().async {
                let count = self.countFilesRecursively(folder)
                
                DispatchQueue.main.async {
                    if let count {
                        lock.lock()
                        
                        folderFileCounts[folder] = count
                        totalFiles += count
                        
                        lock.unlock()
                    } else {
                        folderFileCounts[folder] = nil
                    }
                    
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            
            print(String(format: "Multi-threaded scanned", folderFileCounts.count, "folders in %.3f seconds", timeElapsed))
            print("Total files found:", totalFiles)
            
            completion(folderFileCounts)
        }
    }
}
