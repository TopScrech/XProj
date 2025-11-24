import Foundation

extension Proj {
    func projIcon() -> String? {
        guard let enumerator = assetsEnumerator(at: path) else {
            print("Error: Unable to enumerate the project directory")
            return nil
        }
        
        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent == "Assets.xcassets",
               (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                
                if let iconPath = findAppIcon(in: fileURL) {
                    return iconPath
                }
            }
        }
        
        return nil
    }
    
    private func assetsEnumerator(at path: String) -> FileManager.DirectoryEnumerator? {
        let projectURL = URL(fileURLWithPath: path)
        
        var isDir: ObjCBool = false
        
        guard
            FileManager.default.fileExists(atPath: projectURL.path, isDirectory: &isDir),
            isDir.boolValue
        else {
            print("Error: The path doesn't exist or is not a directory:", projectURL.path)
            return nil
        }
        
        return FileManager.default.enumerator(
            at: projectURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )
    }
    
    private func findAppIcon(in assetsURL: URL) -> String? {
        let fm = FileManager.default
        
        guard let appIconEnumerator = fm.enumerator(
            at: assetsURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            print("Error: Unable to enumerate", assetsURL.path)
            return nil
        }
        
        for case let appIconURL as URL in appIconEnumerator {
            if appIconURL.lastPathComponent == "AppIcon.appiconset",
               (try? appIconURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                return findLargestOrMatchingFile(in: appIconURL)
            }
        }
        
        return nil
    }
    
    private func findLargestOrMatchingFile(in appIconURL: URL) -> String? {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: appIconURL,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles]
            )
            
            // Find the first matching file
            if let firstMatchingFile = fileURLs.first(where: {
                $0.pathExtension.lowercased() != "json" &&
                !$0.lastPathComponent.lowercased().hasPrefix("icon_")
            }) {
                return firstMatchingFile.path
            }
            
            // Find the largest non-JSON file
            let largestFile = fileURLs.filter { $0.pathExtension.lowercased() != "json" }
                .max { url1, url2 in
                    let size1 = (try? url1.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                    let size2 = (try? url2.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                    return size1 < size2
                }
            
            return largestFile?.path
        } catch {
            print("Error accessing files in", appIconURL.path, error.localizedDescription)
            return nil
        }
    }
}
