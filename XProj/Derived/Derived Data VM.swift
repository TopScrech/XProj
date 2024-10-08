import ScrechKit

@Observable
final class DerivedDataVM {
    var folders: [String] = []
    var searchPrompt = ""
    
    private let udKey = "derived_data_bookmark"
    private let fm = FileManager.default
    
    var filteredFolders: [String] {
        guard !searchPrompt.isEmpty else {
            return folders
        }
        
        return folders.filter {
            $0.contains(searchPrompt)
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
        
        for project in projects {
            group.enter()
            
            queue.async {
                defer {
                    group.leave()
                }
                
                self.processProject(project, path: path)
            }
        }
        
        group.wait()
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        folders.append(timeElapsed.description)
        
        print("Time elapsed for processing path: \(String(format: "%.3f", timeElapsed)) seconds")
    }
    
    func processProject(_ project: String, path: String) {
        let projectPath = "\(path)/\(project)"
        
        if project == ".git" || project == ".build" || project == "Not Xcode" {
            return
        }
        
        do {
            let sizeAttribute = try fm.allocatedSizeOfDirectory(atUrl: URL(fileURLWithPath: projectPath))
            
            if project.contains("-") {
                let projectName = project.split(separator: "-").dropLast().joined(separator: "-")
                
                self.folders.append(projectName)
            } else {
                self.folders.append(project)
            }
            
            print("\(project) \(formatBytes(sizeAttribute))")
        } catch {
            print("error processing project at path: \(projectPath)")
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
