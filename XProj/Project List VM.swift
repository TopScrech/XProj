import SwiftUI

@Observable
final class ProjectListVM {
    var projects: [Project] = []
    var searchPrompt = ""
    var projectsFolder = ""
    
    private let udKey = "projects_folder_bookmark"
    private let fm = FileManager.default
    
    var filteredProjects: [Project] {
        if searchPrompt.isEmpty {
            projects
        } else {
            projects.filter {
                $0.name.lowercased().contains(searchPrompt.lowercased())
            }
        }
    }
    
    func findDuplicates() -> [[Project]] {
        var nameCountDict: [String: Int] = [:]
        var duplicates: [[Project]] = []
        
        for project in projects {
            if let count = nameCountDict[project.name] {
                nameCountDict[project.name] = count + 1
            } else {
                nameCountDict[project.name] = 1
            }
            
            if let count = nameCountDict[project.name], count > 1 {
                if !duplicates.contains(where: { $0.first?.name == project.name }) {
                    duplicates.append(projects.filter { $0.name == project.name })
                }
            }
        }
        
        return duplicates
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
            
            let startTime = CFAbsoluteTimeGetCurrent()
            
            try processPath(path)
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Time elapsed for processing path: \(String(format: "%.3f", timeElapsed)) seconds")
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
        
        if let isHidden = attributes[.extensionHidden] as? Bool, isHidden {
            return
        }
        
        if project == ".git" || project == ".build" || project == "Not Xcode" {
            return
        }
        
        if hasXcodeproj(projectPath) {
            fileType = .proj
            
        } else if hasSwiftPackage(projectPath) {
            fileType = .package
            
        } else {
            switch typeAttribute {
            case "NSFileTypeDirectory":
                //                fileType = .folder
                try processPath(projectPath)
                return
                
            default:
                //                fileType = .unknown
                return
            }
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
            
            return Date(timeIntervalSince1970: TimeInterval(statStruct.st_atimespec.tv_sec))
        }
    }
    
    private func hasXcodeproj(_ path: String) -> Bool {
        do {
            let contents = try fm.contentsOfDirectory(atPath: path)
            
            return contents.contains {
                $0.hasSuffix(".xcodeproj")
            }
        } catch {
            return false
        }
    }
    
    private func hasSwiftPackage(_ path: String) -> Bool {
        do {
            let contents = try fm.contentsOfDirectory(atPath: path)
            
            return contents.contains("Package.swift")
        } catch {
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
            
            projectsFolder = url.path
            
            if url.startAccessingSecurityScopedResource() {
                // You can now access the folder here
            }
            
            if isStale {
                print("Bookmark data is stale. Need to reselect folder for a new bookmark")
            }
        } catch {
            print("Error restoring access: \(error)")
        }
    }
}
