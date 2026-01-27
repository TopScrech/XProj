import ScrechKit
import OSLog

@Observable
final class DerivedDataVM {
    var folders: [DerivedDataFolder] = []
    var searchPrompt = ""
    var derivedDataURL: URL?
    
    private let udKey = "derived_data_bookmark"
    
    init() {
        Task.detached(priority: .background) {
            await self.getFolders()
        }
    }
    
    var totalSize: String {
        let sizes = folders
            .map(\.size)
            .reduce(Int64(0), +)
        
        return formatBytes(sizes)
    }
    
    var filteredFolders: [DerivedDataFolder] {
        let sortedFolders = folders.sorted {
            $0.size > $1.size
        }
        let prompt = searchPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard prompt.isEmpty else {
            return sortedFolders.filter {
                $0.name.localizedStandardContains(prompt)
            }
        }
        
        return sortedFolders
    }
    
    func showPicker() {
        BookmarkManager.openFolderPicker { url in
            guard let url else {
                return
            }
            
            BookmarkManager.saveSecurityScopedBookmark(url, forKey: self.udKey) {
                self.getFolders()
            }
        }
    }
    
    func deleteAllFiles() {
        guard let url = derivedDataURL else {
            return
        }
        
        guard FileManager.default.fileExists(atPath: url.path()) else {
            Logger().error("Folder does not exist: \(url)")
            return
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil,
                options: []
            )
            
            for fileURL in contents {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    Logger().error("Failed to delete at 'fileURL.path': \(error)")
                }
            }
        } catch {
            Logger().error("Failed to fetch dir contents at '\(url)': \(error)")
        }
        
        getFolders()
    }
    
    func deleteFile(_ name: String) {
        guard let url = derivedDataURL?.appendingPathComponent(name) else {
            return
        }
        
        guard FileManager.default.fileExists(atPath: url.path()) else {
            Logger().error("File or folder does not exist: \(url)")
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
            Logger().info("Successfully deleted: \(url)")
            
            guard let index = folders.firstIndex(where: {
                $0.name == name
            }) else {
                return
            }
            
            folders.remove(at: index)
        } catch {
            Logger().error("Failed to delete '\(url)': \(error)")
        }
    }
    
    func getFolders() {
        folders = []
        
        guard let url = BookmarkManager.restoreAccessToFolder(udKey) else {
            Logger().error("Unable to restore access to the folder. Please select a folder")
            return
        }
        
        derivedDataURL = url
        
        do {
            try processPath(url.path)
        } catch {
            Logger().error("Error processing path: \(error)")
        }
    }
    
    private func processPath(_ path: String) throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        let foundFolders = try FileManager.default.contentsOfDirectory(atPath: path)
        
        for folder in foundFolders {
            group.enter()
            
            queue.async {
                defer {
                    group.leave()
                }
                
                Task { @MainActor in
                    if let processedFolder = self.processFolder(folder, at: path) {
                        self.folders.append(processedFolder)
                    }
                }
            }
        }
        
        group.wait()
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        let timeElapsedString = timeElapsed.formatted(.fractionDigits(3))
        
        Logger().info("Seconds for processing Derived Data: \(timeElapsedString)")
    }
    
    private func processFolder(_ name: String, at path: String) -> DerivedDataFolder? {
        let path = path + "/" + name
        let url = URL(fileURLWithPath: path)
        
        do {
            let size = try FileManager.default.allocatedSizeOfDirectory(url)
            return DerivedDataFolder(name: name, size: size)
        } catch {
            Logger().error("Can't process project at '\(path)': \(error)")
        }
        
        return nil
    }
}
