import Foundation
import OSLog

func fetchProjFilePath(_ path: String) -> URL? {
    let folderURL = URL(fileURLWithPath: path)
    
    // Find .xcodeproj in the dir
    guard
        let xcodeProjURL = try? FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ).first(where: { $0.pathExtension == "xcodeproj" }),
        FileManager.default.fileExists(atPath: xcodeProjURL.path)
    else {
        // Check if .xcodeproj exists
        Logger().error("Project file not found")
        return nil
    }
    
    return xcodeProjURL
}
