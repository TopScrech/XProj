import SwiftUI

@Observable
final class ProjListVM {
#warning("Make private")
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
    
    func openProjects(_ paths: [String]) {
        for path in paths {
            let (found, filePath) = findXcodeprojFile(path)
            
            if found, let filePath {
                launchProj(filePath)
            } else {
                launchProj(path + "/Package.swift")
            }
        }
    }
    
    func findDuplicates() -> [[Project]] {
        var nameCountDict: [String: Int] = [:]
        var duplicates: [[Project]] = []
        
        for proj in projects {
            if let count = nameCountDict[proj.name] {
                nameCountDict[proj.name] = count + 1
            } else {
                nameCountDict[proj.name] = 1
            }
            
            if let count = nameCountDict[proj.name], count > 1 {
                if !duplicates.contains(where: { $0.first?.name == proj.name }) {
                    duplicates.append(projects.filter { $0.name == proj.name })
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
        
        for proj in projects {
            try processProj(atPath: path, proj: proj)
        }
    }
    
    func processProj(atPath path: String, proj: String) throws {
        let projPath = "\(path)/\(proj)"
        let attributes = try fm.attributesOfItem(atPath: projPath)
        
        let typeAttribute = attributes[.type] as? String ?? "Other"
        let fileType: ProjType
        
        if let isHidden = attributes[.extensionHidden] as? Bool, isHidden {
            return
        }
        
        if proj == ".git" || proj == ".build" || proj == "Not Xcode" {
            return
        }
        
        if hasXcodeProj(projPath) {
            fileType = .proj
            
        } else if hasSwiftPackage(projPath) {
            fileType = .package
            
        } else {
            switch typeAttribute {
            case "NSFileTypeDirectory":
                //                fileType = .folder
                try processPath(projPath)
                return
                
            default:
                //                fileType = .unknown
                return
            }
        }
        
        guard let lastOpened = lastAccessDate(projPath) else {
            return
        }
        
        self.projects.append(
            .init(
                name: proj,
                path: projPath,
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
    
    private func hasXcodeProj(_ path: String) -> Bool {
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
