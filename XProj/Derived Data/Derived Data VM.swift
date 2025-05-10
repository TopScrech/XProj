import ScrechKit

@Observable
final class DerivedDataVM {
    private(set) var folders: [DerivedDataFolder] = []
    var searchPrompt = ""
    
    private let udKey = "derived_data_bookmark"
    private let fm = FileManager.default
    
    private(set) var derivedDataUrl: URL?
    
    init() {
        DispatchQueue.global(qos: .background).async {
            self.getFolders()
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
        
        guard searchPrompt.isEmpty else {
            return sortedFolders.filter {
                $0.name.contains(searchPrompt)
            }
        }
        
        return sortedFolders
    }
    
    func showPicker() {
        openFolderPicker { url in
            guard let url else {
                return
            }
            
            saveSecurityScopedBookmark(url, forKey: self.udKey) {
                self.getFolders()
            }
        }
    }
    
    func deleteAllFiles() {
        guard let url = derivedDataUrl else {
            return
        }
        
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: url.path()) else {
            print("Folder does not exist:", url)
            return
        }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            
            for fileURL in contents {
                do {
                    try fileManager.removeItem(at: fileURL)
                } catch {
                    print("Failed to delete file: \(fileURL.path), error:", error.localizedDescription)
                }
            }
        } catch {
            print("Failed to fetch contents of directory: \(url), error:", error.localizedDescription)
        }
        
        getFolders()
    }
    
    func deleteFile(_ name: String) {
        guard let url = derivedDataUrl?.appendingPathComponent(name) else {
            return
        }
        
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: url.path()) else {
            print("File or folder does not exist:", url)
            return
        }
        
        do {
            try fm.removeItem(at: url)
            print("Successfully deleted:", url)
            
            guard let index = folders.firstIndex(where: {
                $0.name == name
            }) else {
                return
            }
            
            folders.remove(at: index)
        } catch {
            print("Failed to delete: \(url), error:", error.localizedDescription)
        }
    }
    
    func getFolders() {
        folders = []
        
        guard let url = restoreAccessToFolder(udKey) else {
            print("Unable to restore access to the folder. Please select a folder")
            return
        }
        
        derivedDataUrl = url
        
        do {
            try processPath(url.path)
        } catch {
            print("Error processing path: \(error.localizedDescription)")
        }
    }
    
    private func processPath(_ path: String) throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        let foundFolders = try fm.contentsOfDirectory(atPath: path)
        
        for folder in foundFolders {
            group.enter()
            
            queue.async {
                defer {
                    group.leave()
                }
                
                if let processedFolder = self.processFolder(folder, at: path) {
                    self.folders.append(processedFolder)
                }
            }
        }
        
        group.wait()
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for processing Derived Data: \(String(format: "%.3f", timeElapsed))s")
    }
    
    private func processFolder(_ name: String, at path: String) -> DerivedDataFolder? {
        let path = path + "/" + name
        let url = URL(fileURLWithPath: path)
        
        do {
            let size = try fm.allocatedSizeOfDirectory(url)
            
            return DerivedDataFolder(
                name: name,
                size: size
            )
        } catch {
            print("error processing project at path:", path)
        }
        
        return nil
    }
}
