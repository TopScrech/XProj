import Foundation

extension Proj {
    func projIcon() -> String? {
        let fileManager = FileManager.default
        let projectUrl = URL(fileURLWithPath: path)
        
        var isDir: ObjCBool = false
        
        guard
            fileManager.fileExists(atPath: projectUrl.path, isDirectory: &isDir),
            isDir.boolValue
        else {
            print("Error: The path '\(projectUrl.path)' does not exist or is not a directory")
            return nil
        }
        
        // Use FileManager's enumerator to traverse the directory recursively
        guard let enumerator = fileManager.enumerator(
            at: projectUrl,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            print("Error: Unable to enumerate the project directory")
            return nil
        }
        
        // Traverse through the enumerator to find Assets.xcassets directories
        for case let fileUrl as URL in enumerator {
            if fileUrl.lastPathComponent == "Assets.xcassets",
               (try? fileUrl.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                
                // Now search for AppIcon.appiconset within this Assets.xcassets
                guard let appIconEnumerator = fileManager.enumerator(
                    at: fileUrl,
                    includingPropertiesForKeys: [.isDirectoryKey],
                    options: [.skipsHiddenFiles, .skipsPackageDescendants]
                ) else {
                    print("Error: Unable to enumerate \(fileUrl.path)")
                    continue
                }
                
                for case let appIconUrl as URL in appIconEnumerator {
                    if appIconUrl.lastPathComponent == "AppIcon.appiconset",
                       (try? appIconUrl.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                        
                        do {
                            let fileURLs = try fileManager.contentsOfDirectory(
                                at: appIconUrl,
                                includingPropertiesForKeys: nil,
                                options: [.skipsHiddenFiles]
                            )
                            
                            let firstMatchingFile = fileURLs.first(where: {
                                let isNotJSON = $0.pathExtension.lowercased() != "json"
                                let doesNotStartWithIcon = !$0.lastPathComponent.lowercased().hasPrefix("icon_")
                                
                                return isNotJSON && doesNotStartWithIcon
                            })
                            
                            if let firstMatchingFile {
                                return firstMatchingFile.path
                            } else {
                                let nonJSONFiles = fileURLs.filter {
                                    $0.pathExtension.lowercased() != "json"
                                }
                                
                                let largestFile = nonJSONFiles.max { url, url2 in
                                    let size1 = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                                    let size2 = (try? url2.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                                    
                                    return size1 < size2
                                }
                                
                                if let largestFile {
                                    return largestFile.path
                                }
                            }
                        } catch {
                            print("Error accessing files in \(appIconUrl.path): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
        return nil
    }
}
