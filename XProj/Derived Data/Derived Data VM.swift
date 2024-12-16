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
                    $0.size < $1.size
                }
                .filter {
                    $0.name.contains(searchPrompt)
                }
        }
        
        return folders
            .sorted {
                $0.size < $1.size
            }
    }
    
    func getFolders() {
        restoreAccessToFolder()
        folders = []
        
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
        
        let projects = try fm.contentsOfDirectory(atPath: path)
        
        for proj in projects {
            group.enter()
            
            queue.async {
                defer {
                    group.leave()
                }
                
                self.processFolder(proj, path: path)
            }
        }
        
        group.wait()
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        print("Time elapsed for processing path: \(String(format: "%.3f", timeElapsed)) seconds")
    }
    
    func processFolder(_ proj: String, path: String) {
        let path = "\(path)/\(proj)"
        
        if proj == ".git" || proj == ".build" || proj == "Not Xcode" {
            return
        }
        
        do {
            let sizeAttribute = try fm.allocatedSizeOfDirectory(atUrl: URL(fileURLWithPath: path))
            
            let name: String
            
            if proj.contains("-") {
                name = proj.split(separator: "-").dropLast().joined(separator: "-")
            } else {
                name = proj
            }
            
            let folder = DerivedDataFolder(
                name: name,
                size: sizeAttribute
            )
            
            folders.append(folder)
        } catch {
            print("error processing project at path: \(path)")
        }
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
