import Foundation

func fetchProjFilePath(_ path: String) -> URL? {
    let fm = FileManager.default
    let folderURL = URL(fileURLWithPath: path)
    
    // Find .xcodeproj in the dir
    guard
        let xcodeProjURL = try? fm.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ).first(where: { $0.pathExtension == "xcodeproj" })
    else {
        print("projectFileNotFound")
        return nil
    }
    
    // Check if .xcodeproj exists
    guard fm.fileExists(atPath: xcodeProjURL.path) else {
        print("projectFileNotFound")
        return nil
    }
    
    return xcodeProjURL
}
