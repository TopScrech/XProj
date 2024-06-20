import Foundation

extension ProjectListVM {
    func listFilesInFoldersSingleThread(folderPaths: [String]) -> [String: [String]?] {
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
        print(String(format: "Single-threaded scanned \(folderContents.count) folders in %.3f seconds", timeElapsed))
        print("Total files found: \(totalFiles)")
        
        return folderContents
    }
    
    func listFilesRecursively(_ folder: String) -> [String]? {
        var allFiles = [String]()
        
        do {
            let filesAndFolders = try FileManager.default.contentsOfDirectory(atPath: folder)
            
            for item in filesAndFolders {
                var isDirectory: ObjCBool = false
                let fullPath = (folder as NSString).appendingPathComponent(item)
                let isExisting = FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDirectory)
                
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
    
    func countFilesInFoldersSingleThread(folderPaths: [String]) -> [String: Int?] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderFileCounts = [String: Int?]()
        var totalFiles = 0
        
        for folder in folderPaths {
            if let count = countFilesRecursively(in: folder) {
                folderFileCounts[folder] = count
                totalFiles += count
            } else {
                folderFileCounts[folder] = nil
            }
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print(String(format: "Single-threaded scanned \(folderFileCounts.count) folders in %.3f seconds", timeElapsed))
        print("Total files found: \(totalFiles)")
        
        return folderFileCounts
    }
    
    func countFilesRecursively(in folder: String) -> Int? {
        var fileCount = 0
        
        do {
            let filesAndFolders = try FileManager.default.contentsOfDirectory(atPath: folder)
            
            for item in filesAndFolders {
                var isDirectory: ObjCBool = false
                let fullPath = (folder as NSString).appendingPathComponent(item)
                let isExisting = FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDirectory)
                
                guard isExisting else {
                    return nil
                }
                
                if isDirectory.boolValue {
                    if let nestedCount = countFilesRecursively(in: fullPath) {
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

//extension ProjectListVM {
//    func listFilesInFoldersMultiThread(folderPaths: [String], completion: @escaping ([String: [String]?]) -> Void) {
//        let startTime = CFAbsoluteTimeGetCurrent()
//
//        var folderContents = [String: [String]?]()
//        let dispatchGroup = DispatchGroup()
//        let lock = NSLock()
//        var totalFiles = 0
//
//        for folder in folderPaths {
//            dispatchGroup.enter()
//            DispatchQueue.global().async {
//                let files = self.listFilesRecursively(in: folder)
//                DispatchQueue.main.async {
//                    if let files = files {
//                        lock.lock()
//                        folderContents[folder] = files
//                        totalFiles += files.count
//                        lock.unlock()
//                    } else {
//                        folderContents[folder] = nil
//                    }
//                    dispatchGroup.leave()
//                }
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
//            print(String(format: "Multi-threaded scanned \(folderContents.count) folders in %.3f seconds", timeElapsed))
//            print("Total files found: \(totalFiles)")
//            completion(folderContents)
//        }
//    }
//
//    func countFilesInFoldersMultiThread(folderPaths: [String], completion: @escaping ([String: Int?]) -> Void) {
//        let startTime = CFAbsoluteTimeGetCurrent()
//
//        var folderFileCounts = [String: Int?]()
//        let dispatchGroup = DispatchGroup()
//        let lock = NSLock()
//        var totalFiles = 0
//
//        for folder in folderPaths {
//            dispatchGroup.enter()
//            DispatchQueue.global().async {
//                let count = self.countFilesRecursively(in: folder)
//                DispatchQueue.main.async {
//                    if let count = count {
//                        lock.lock()
//                        folderFileCounts[folder] = count
//                        totalFiles += count
//                        lock.unlock()
//                    } else {
//                        folderFileCounts[folder] = nil
//                    }
//                    dispatchGroup.leave()
//                }
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
//            print(String(format: "Multi-threaded scanned \(folderFileCounts.count) folders in %.3f seconds", timeElapsed))
//            print("Total files found: \(totalFiles)")
//            completion(folderFileCounts)
//        }
//    }
//}

extension ProjectListVM {
    func listFilesInFoldersMultiThread(folderPaths: [String], completion: @escaping ([String: [String]?]) -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderContents = [String: [String]?]()
        let dispatchGroup = DispatchGroup()
        let lock = NSLock()
        var totalFiles = 0
        
        for folder in folderPaths {
            dispatchGroup.enter()
            
            DispatchQueue.global().async {
                let files = self.listFilesRecursively(folder)
                
                DispatchQueue.main.async {
                    if let files = files {
                        lock.lock()
                        
                        folderContents[folder] = files
                        totalFiles += files.count
                        
                        lock.unlock()
                    } else {
                        folderContents[folder] = nil
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            
            print(String(format: "Multi-threaded scanned \(folderContents.count) folders in %.3f seconds", timeElapsed))
            print("Total files found: \(totalFiles)")
            
            completion(folderContents)
        }
    }
    
    func countFilesInFoldersMultiThread(folderPaths: [String], completion: @escaping ([String: Int?]) -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderFileCounts = [String: Int?]()
        let dispatchGroup = DispatchGroup()
        let lock = NSLock()
        var totalFiles = 0
        
        for folder in folderPaths {
            dispatchGroup.enter()
            
            DispatchQueue.global().async {
                let count = self.countFilesRecursively(in: folder)
                
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
            
            print(String(format: "Multi-threaded scanned \(folderFileCounts.count) folders in %.3f seconds", timeElapsed))
            print("Total files found: \(totalFiles)")
            
            completion(folderFileCounts)
        }
    }
}
