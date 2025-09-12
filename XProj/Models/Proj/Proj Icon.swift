import Foundation

extension Proj {
    func projIcon() -> String? {
        guard let enumerator = assetsEnumerator(at: path) else {
            print("Error: Unable to enumerate the project directory")
            return nil
        }
        
        for case let fileUrl as URL in enumerator {
            if fileUrl.lastPathComponent == "Assets.xcassets",
               (try? fileUrl.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                if let iconPath = findAppIcon(in: fileUrl) {
                    return iconPath
                }
            }
        }
        
        return nil
    }
        
    private func assetsEnumerator(at path: String) -> FileManager.DirectoryEnumerator? {
        let fm = FileManager.default
        let projectUrl = URL(fileURLWithPath: path)
        
        var isDir: ObjCBool = false
        
        guard
            fm.fileExists(atPath: projectUrl.path, isDirectory: &isDir),
            isDir.boolValue
        else {
            print("Error: The path doesn't exist or is not a directory:", projectUrl.path)
            return nil
        }
        
        return fm.enumerator(
            at: projectUrl,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )
    }
    
    private func findAppIcon(in assetsUrl: URL) -> String? {
        let fm = FileManager.default
        
        guard let appIconEnumerator = fm.enumerator(
            at: assetsUrl,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            print("Error: Unable to enumerate", assetsUrl.path)
            return nil
        }
        
        for case let appIconUrl as URL in appIconEnumerator {
            if appIconUrl.lastPathComponent == "AppIcon.appiconset",
               (try? appIconUrl.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                return findLargestOrMatchingFile(in: appIconUrl)
            }
        }
        
        return nil
    }
    
    private func findLargestOrMatchingFile(in appIconUrl: URL) -> String? {
        let fm = FileManager.default
        
        do {
            let fileURLs = try fm.contentsOfDirectory(
                at: appIconUrl,
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
            print("Error accessing files in \(appIconUrl.path):", error.localizedDescription)
            return nil
        }
    }
}
