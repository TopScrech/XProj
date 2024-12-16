import ScrechKit

@Observable
final class DerivedDataVM {
    var folders: [DerivedDataFolder] = []
    var searchPrompt = ""
    
    private let udKey = "derived_data_bookmark"
    private let fm = FileManager.default
    
    var filteredFolders: [DerivedDataFolder] {
        guard searchPrompt.isEmpty else {
            return folders
                .sorted {
                    $0.size > $1.size
                }
                .filter {
                    $0.name.contains(searchPrompt)
                }
        }
        
        return folders
            .sorted {
                $0.size > $1.size
            }
    }
    
    func getFolders() {
        restoreAccessToFolder()
        
        do {
            guard let bookmarkData = UserDefaults.standard.data(forKey: udKey) else {
                return
            }
            
            var isStale = false
            
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                bookmarkDataIsStale: &isStale
            )
            
            let path = url.path
            
            if isStale {
                print("Bookmark data is stale. Need to reselect folder for a new bookmark")
                return
            }
            
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to start accessing security scoped resource")
                return
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            try processPath(path)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func processPath(_ path: String) throws {
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
                
                if let processedFolder = self.processFolder(folder, path: path) {
                    fetchedFolders.append(processedFolder)
                }
            }
        }
        
        group.wait()
        
        folders = fetchedFolders
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for processing path: \(String(format: "%.3f", timeElapsed)) seconds")
    }
    
    func processFolder(_ proj: String, path: String) -> DerivedDataFolder? {
        let path = "\(path)/\(proj)"
        
        if proj == ".git" || proj == ".build" || proj == "Not Xcode" {
            return nil
        }
        
        do {
            let sizeAttribute = try fm.allocatedSizeOfDirectory(atUrl: URL(fileURLWithPath: path))
            
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
    
    func openFolderPicker() {
        let panel = NSOpenPanel()
        
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.saveBookmark(url)
            }
        }
    }
    
    private func saveBookmark(_ url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            UserDefaults.standard.set(bookmarkData, forKey: udKey)
            
            getFolders()
        } catch {
            print("Error saving bookmark: \(error)")
        }
    }
    
    func restoreAccessToFolder() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: udKey) else {
            return
        }
        
        var isStale = false
        
        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            if url.startAccessingSecurityScopedResource() {
                // You can now access the folder here
#warning("Remember to call `stopAccessingSecurityScopedResource()` when access is no longer needed")
            }
            
            if isStale {
                // Bookmark data is stale, need to save a new bookmark
                print("Bookmark data is stale. Need to reselect folder for a new bookmark")
            }
        } catch {
            print("Error restoring access: \(error)")
        }
    }
}
