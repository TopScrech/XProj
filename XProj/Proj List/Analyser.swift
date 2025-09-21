import Foundation

extension DataModel {
    func listFilesInFoldersSingleThread(_ folderPaths: [String]) async -> [String: [String]?] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderContents = [String: [String]?]()
        var totalFiles = 0
        
        for folder in folderPaths {
            if let files = await DataModel.listFilesRecursively(folder) {
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
    
    func countFilesInFoldersSingleThread(_ folderPaths: [String]) async -> [String: Int?] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderFileCounts = [String: Int?]()
        var totalFiles = 0
        
        for folder in folderPaths {
            if let count = await countFilesRecursively(folder) {
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
    
    func countFilesRecursively(_ folder: String) async -> Int? {
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
                    if let nestedCount = await countFilesRecursively(fullPath) {
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
    static func listFilesRecursively(_ folder: String) async -> [String]? {
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
                    if let nestedFiles = await listFilesRecursively(fullPath) {
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
    
    func countFilesInFoldersMultiThread(_ folderPaths: [String]) async -> [String: Int?] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var folderFileCounts = [String: Int?]()
        var totalFiles = 0
        
        await withTaskGroup(of: (String, Int?).self) { group in
            for folder in folderPaths {
                group.addTask {
                    let count = await self.countFilesRecursively(folder)
                    return (folder, count)
                }
            }
            
            for await (folder, count) in group {
                if let count {
                    folderFileCounts[folder] = count
                    totalFiles += count
                } else {
                    folderFileCounts[folder] = nil
                }
            }
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        print(String(format: "Multi-threaded scanned %d folders in %.3f seconds", folderFileCounts.count, timeElapsed))
        print("Total files found:", totalFiles)
        
        return folderFileCounts
    }
}
