import SwiftUI

@Observable
final class ProjectListVM {
    var projects: [Project] = []
    var searchPrompt = ""
    
    private let udKey = "projects_folder_bookmark"
    private let fm = FileManager.default
    
    var filteredProjects: [Project] {
        if searchPrompt.isEmpty {
            projects
        } else {
            projects.filter {
                $0.name.contains(searchPrompt)
            }
        }
    }
    
    var lastOpenedProjects: [Project] {
        projects.filter {
            $0.type == .proj
        }
        .prefix(5).sorted {
            $0.lastOpened > $1.lastOpened
        }
    }
    
    func getFolders() {
        restoreAccessToFolder()
        projects = []
        
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
            
            let path = url.path
            
            try processPath(path)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func processPath(_ path: String) throws {
        let projects = try fm.contentsOfDirectory(atPath: path)
        
        for project in projects {
            try processProject(atPath: path, project: project)
        }
    }
    
    func processProject(atPath path: String, project: String) throws {
        let projectPath = "\(path)/\(project)"
        let attributes = try fm.attributesOfItem(atPath: projectPath)
        
        let typeAttribute = attributes[.type] as? String ?? "Other"
        let fileType: FileType
        
        if hasXcodeproj("\(path)/\(project)") {
            fileType = .proj
        } else {
            switch typeAttribute {
            case "NSFileTypeDirectory":
                fileType = .folder
                
            default:
                fileType = .unknown
            }
        }
        
        if let isHidden = attributes[.extensionHidden] as? Bool, isHidden {
            return
        }
        
        guard let lastOpened = lastAccessDate(projectPath) else {
            return
        }
        
        self.projects.append(
            .init(
                name: project,
                path: projectPath,
                type: fileType,
                lastOpened: lastOpened,
                attributes: attributes
            )
        )
    }
        
    func lastAccessDate(_ path: String) -> Date? {
        path.withCString {
            var statStruct = Darwin.stat()
            
            guard  stat($0, &statStruct) == 0 else {
                return nil
            }
            
            return Date(
                timeIntervalSince1970: TimeInterval(statStruct.st_atimespec.tv_sec)
            )
        }
    }
        
    private func hasXcodeproj(_ path: String) -> Bool {
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            
            return contents.contains {
                $0.hasSuffix(".xcodeproj")
            }
        } catch {
            print("Failed to read directory contents: \(path)")
            return false
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
                print("Bookmark data is stale. Need to reselect folder for a new bookmark.")
            }
        } catch {
            print("Error restoring access: \(error)")
        }
    }
}
