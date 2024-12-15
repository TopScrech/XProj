import Foundation

extension Project {
    func projIcon() -> String? {
        let fileManager = FileManager.default
        let projectURL = URL(fileURLWithPath: path)
        
        var isDir: ObjCBool = false
        
        guard
            fileManager.fileExists(atPath: projectURL.path, isDirectory: &isDir),
            isDir.boolValue
        else {
            print("Error: The path '\(projectURL.path)' does not exist or is not a directory")
            return nil
        }
        
        // Use FileManager's enumerator to traverse the directory recursively
        guard let enumerator = fileManager.enumerator(at: projectURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            print("Error: Unable to enumerate the project directory")
            return nil
        }
        
        // Traverse through the enumerator to find Assets.xcassets directories
        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent == "Assets.xcassets",
               (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                
                // Now search for AppIcon.appiconset within this Assets.xcassets
                guard let appIconEnumerator = fileManager.enumerator(at: fileURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
                    print("Error: Unable to enumerate \(fileURL.path)")
                    continue
                }
                
                for case let appIconURL as URL in appIconEnumerator {
                    if appIconURL.lastPathComponent == "AppIcon.appiconset",
                       (try? appIconURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                        
                        // List files in AppIcon.appiconset & apply filter
                        do {
                            let fileURLs = try fileManager.contentsOfDirectory(at: appIconURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                            
                            if let firstMatchingFile = fileURLs.first(where: {
                                let isNotJSON = $0.pathExtension.lowercased() != "json"
                                let doesNotStartWithIcon = !$0.lastPathComponent.lowercased().hasPrefix("icon_")
                                return isNotJSON && doesNotStartWithIcon
                            }) {
                                return firstMatchingFile.path
                            }
                        } catch {
                            print("Error accessing files in \(appIconURL.path): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
        return nil
    }
}
