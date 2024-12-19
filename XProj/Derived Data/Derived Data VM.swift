import ScrechKit

@Observable
final class DerivedDataVM {
    var folders: [DerivedDataFolder] = []
    var searchPrompt = ""
    
    private let udKey = "derived_data_bookmark"
    private let fm = FileManager.default
    
    var totalSize: String {
        formatBytes(folders.map(\.size).reduce(Int64(0), +))
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
            
            saveSecurityScopedBookmark(url: url, forKey: self.udKey) {
                self.getFolders()
            }
        }
    }
    
    func getFolders() {
        guard let url = FolderAccessManager.shared.restoreAccessToFolder(udKey) else {
            print("Unable to restore access to the folder. Please select a folder.")
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
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
        
        var fetchedFolders: [DerivedDataFolder] = []
        
        for folder in foundFolders {
            group.enter()
            
            queue.async {
                defer {
                    group.leave()
                }
                
                if let processedFolder = self.processFolder(folder, at: path) {
                    fetchedFolders.append(processedFolder)
                }
            }
        }
        
        group.wait()
        
        folders = fetchedFolders
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for processing path: \(String(format: "%.3f", timeElapsed)) seconds")
    }
    
    private func processFolder(_ proj: String, at path: String) -> DerivedDataFolder? {
        let path = path + "/" + proj
        let url = URL(fileURLWithPath: path)
        
        if proj == ".git" || proj == ".build" || proj == "Not Xcode" {
            return nil
        }
        
        do {
            let sizeAttribute = try fm.allocatedSizeOfDirectory(url)
            
            let name: String
            
            if proj.contains("-") {
                name = proj.split(separator: "-").dropLast().joined(separator: "-")
            } else {
                name = proj
            }
            
            return DerivedDataFolder(
                name: name,
                size: sizeAttribute
            )
        } catch {
            print("error processing project at path: \(path)")
        }
        
        return nil
    }
}
