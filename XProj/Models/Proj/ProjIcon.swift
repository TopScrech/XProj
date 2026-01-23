import Foundation
import OSLog

extension Proj {
    func projIcon() -> String? {
        guard let enumerator = assetsEnumerator(at: path) else {
            Logger().error("Unable to enumerate the project directory")
            return nil
        }
        
        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent == "Assets.xcassets",
               (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                
                if let iconPath = findAppIcon(in: fileURL) {
                    return iconPath
                }
            }
            
            if fileURL.lastPathComponent == "AppIcon.icon",
               (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true,
               let iconPath = findBestIconFile(in: fileURL) {
                return iconPath
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
            Logger().error("Path doesn't exist or isn't a dir: \(projectURL.path)")
            return nil
        }
        
        return FileManager.default.enumerator(
            at: projectURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )
    }
    
    private func findAppIcon(in assetsURL: URL) -> String? {
        guard let appIconEnumerator = FileManager.default.enumerator(
            at: assetsURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            Logger().error("Unable to enumerate at \(assetsURL.path)")
            return nil
        }
        
        for case let appIconURL as URL in appIconEnumerator {
            if appIconURL.lastPathComponent == "AppIcon.appiconset",
               (try? appIconURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                return findBestAppIconFile(in: appIconURL)
            }
        }
        
        return nil
    }
    
    private func findBestAppIconFile(in appIconURL: URL) -> String? {
        if let bestFromContents = bestAppIconFromContents(appIconURL) {
            return bestFromContents
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: appIconURL,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles]
            )
            
            // Find the largest non-JSON file
            let largestFile = fileURLs.filter { $0.pathExtension.lowercased() != "json" }
                .max {
                    let size1 = (try? $0.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                    let size2 = (try? $1.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                    return size1 < size2
                }
            
            return largestFile?.path
        } catch {
            Logger().error("Error accessing files at '\(appIconURL.path)': \(error)")
            return nil
        }
    }

    private func findBestIconFile(in appIconURL: URL) -> String? {
        if let bestFromIconJSON = bestIconFromIconJSON(appIconURL) {
            return bestFromIconJSON
        }
        
        if let bestFromAssets = largestImageFile(in: appIconURL.appendingPathComponent("Assets")) {
            return bestFromAssets
        }
        
        return largestImageFile(in: appIconURL)
    }

    private func bestIconFromIconJSON(_ appIconURL: URL) -> String? {
        let contentsURL = appIconURL.appendingPathComponent("icon.json")
        
        guard
            let data = try? Data(contentsOf: contentsURL),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let groups = json["groups"] as? [[String: Any]]
        else {
            return nil
        }
        
        for group in groups {
            guard let layers = group["layers"] as? [[String: Any]] else {
                continue
            }
            
            for layer in layers {
                if let imageName = layer["image-name"] as? String {
                    let imageURL = appIconURL
                        .appendingPathComponent("Assets")
                        .appendingPathComponent(imageName)
                    
                    if FileManager.default.fileExists(atPath: imageURL.path) {
                        return imageURL.path
                    }
                }
            }
        }
        
        return nil
    }

    private func largestImageFile(in folderURL: URL) -> String? {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles]
            )
            
            let largestFile = fileURLs
                .filter { isImageFile($0) }
                .max {
                    let size1 = (try? $0.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                    let size2 = (try? $1.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                    return size1 < size2
                }
            
            return largestFile?.path
        } catch {
            Logger().error("Error accessing files at '\(folderURL.path)': \(error)")
            return nil
        }
    }
    
    private func isImageFile(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ext == "png" || ext == "jpg" || ext == "jpeg" || ext == "heic" || ext == "tiff"
    }
    
    private func bestAppIconFromContents(_ appIconURL: URL) -> String? {
        let contentsURL = appIconURL.appendingPathComponent("Contents.json")
        
        guard
            let data = try? Data(contentsOf: contentsURL),
            let contents = try? JSONDecoder().decode(AppIconContents.self, from: data)
        else {
            return nil
        }
        
        let candidates = contents.images.compactMap { image -> (path: String, score: Double)? in
            guard
                let fileName = image.filename,
                !fileName.lowercased().hasPrefix("icon_")
            else {
                return nil
            }
            
            let fileURL = appIconURL.appendingPathComponent(fileName)
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return nil
            }
            
            let pixelSize = image.pixelSize ?? image.derivedPixelSizeFromFilename
            guard pixelSize > 0 else {
                return nil
            }
            
            return (fileURL.path, pixelSize)
        }
        
        return candidates.max(by: { $0.score < $1.score })?.path
    }
}

private struct AppIconContents: Decodable {
    let images: [AppIconImage]
}

private struct AppIconImage: Decodable {
    let filename: String?
    let size: String?
    let scale: String?
    
    var pixelSize: Double? {
        guard
            let size,
            let scale
        else {
            return nil
        }
        
        let baseSize = size
            .split(separator: "x")
            .compactMap { Double($0) }
            .max() ?? 0
        let scaleValue = Double(scale.replacingOccurrences(of: "x", with: "")) ?? 1
        
        guard baseSize > 0 else {
            return nil
        }
        
        return baseSize * scaleValue
    }
    
    var derivedPixelSizeFromFilename: Double {
        guard let filename else {
            return 0
        }
        
        let digits = filename
            .split { !$0.isNumber }
            .compactMap { Double($0) }
        
        return digits.max() ?? 0
    }
}
