import SwiftUI

@Observable
final class ProjListVM {
#warning("Make private")
    var projects: [Project] = []
    var searchPrompt = ""
    var projectsFolder = ""
    
    private let udKey = "projects_folder_bookmark"
    private let fm = FileManager.default
    
    var lastOpenedProjects: [Project] {
        projects.filter {
            $0.type == .proj
        }
        .prefix(5).sorted {
            $0.openedAt > $1.openedAt
        }
    }
    
    var swiftToolsVersions: String {
        var versions = Set<String>()
        
        for proj in projects {
            if let version = proj.swiftToolsVersion {
                versions.insert(version)
            }
        }
        
        let sortedArray = versions.sorted()
        
        let joinedString = sortedArray.joined(separator: ", ")
        
        return joinedString + ","
    }
    
    init() {
        getFolders()
    }
    
    var projectCount: Int {
        projects.filter {
            $0.type == .proj
        }.count
    }
    
    var packageCount: Int {
        projects.filter {
            $0.type == .package
        }.count
    }
    
    var playgroundCount: Int {
        projects.filter {
            $0.type == .playground
        }.count
    }
    
    var workspaceCount: Int {
        projects.filter {
            $0.type == .workspace
        }.count
    }
    
    var vaporCount: Int {
        projects.filter {
            $0.type == .vapor
        }.count
    }
    
    var filteredProjects: [Project] {
        let sortedProjects = projects.sorted {
            $0.openedAt > $1.openedAt
        }
        
        guard !searchPrompt.isEmpty else {
            return sortedProjects
        }
        
        return sortedProjects.filter {
            $0.name.lowercased().contains(searchPrompt.lowercased())
        }
    }
    
    func openProj(_ proj: Project) {
        let path = proj.path
        findProj(path)
    }
    
    func openProjects(_ selectedProjects: Set<Project.ID>) {
        let selected = projects.filter {
            selectedProjects.contains($0.id)
        }
        
        let paths = selected.map(\.path)
        
        for path in paths {
            findProj(path)
        }
    }
    
    private func findProj(_ path: String) {
        let (found, filePath) = findXcodeprojFile(path)
        
        if found, let filePath {
            launchProj(filePath)
        } else {
            launchProj(path + "/Package.swift")
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
                let hasDuplicates = duplicates.contains(where: {
                    $0.first?.name == proj.name
                })
                
                if !hasDuplicates {
                    duplicates.append(projects.filter {
                        $0.name == proj.name
                    })
                }
            }
        }
        
        return duplicates
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
    
    func restoreAccessToFolderOld() {
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
    
    func getFolders() {
        let startTime = CFAbsoluteTimeGetCurrent()
        restoreAccessToFolderOld()
        projects = []
        
        guard let url = FolderAccessManager.shared.restoreAccessToFolder(udKey) else {
            print("Unable to restore access to the folder. Please select a new folder")
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
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for processing path: \(String(format: "%.3f", timeElapsed)) seconds")
    }
    
    private func processPath(_ path: String) throws {
        let projects = try fm.contentsOfDirectory(atPath: path)
        
        for proj in projects {
            try processProj(proj, at: path)
        }
    }
    
    private func processProj(_ proj: String, at path: String) throws {
        let projPath = path + "/" + proj
        let attributes = try fm.attributesOfItem(atPath: projPath)
        
        let typeAttribute = attributes[.type] as? String ?? "Other"
        
        if let isHidden = attributes[.extensionHidden] as? Bool, isHidden {
            return
        }
        
        if proj == ".git" || proj == ".build" || proj == "Not Xcode" {
            return
        }
        
        let fileType: ProjType
        
#warning("Workspaces are not fully supported")
        if hasFile(ofType: "xcodeproj", at: projPath) {
            if hasFile(ofType: "xcworkspace", at: projPath) {
                fileType = .workspace
            } else {
                fileType = .proj
            }
            
        } else if hasSwiftPackage(projPath) {
            fileType = hasVapor(projPath) ? .vapor : .package
            
            //            if isVapor(proj, path) {
            //                fileType = .vapor
            //            } else {
            //                fileType = .package
            //            }
            
        } else if proj.contains(".playground") {
            fileType = .playground
            
        } else {
            switch typeAttribute {
            case "NSFileTypeDirectory":
                try processPath(projPath)
                return
                
            default:
                return
            }
        }
        
        guard let openedAt = lastAccessDate(projPath) else {
            return
        }
        
        let modifiedAt = attributes[.modificationDate] as? Date
        let createdAt = attributes[.creationDate] as? Date
        
        self.projects.append(
            Project(
                name: proj,
                path: projPath,
                type: fileType,
                openedAt: openedAt,
                modifiedAt: modifiedAt,
                createdAt: createdAt,
                attributes: attributes
            )
        )
    }
    
    private func hasVapor( _ path: String) -> Bool {
        let fm = FileManager.default
        
        let filePath = path + "/Package.resolved"
        let vaporUrl = "https://github.com/vapor/vapor.git"
        
        guard fm.fileExists(atPath: path) else {
            return false
        }
        
        do {
            let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
            
            let containsVapor = fileContents.contains(vaporUrl)
            
            return containsVapor
        } catch {
            return false
        }
    }
    
    private func lastAccessDate(_ path: String) -> Date? {
        path.withCString {
            var statStruct = Darwin.stat()
            
            guard stat($0, &statStruct) == 0 else {
                return nil
            }
            
            let interval = TimeInterval(statStruct.st_atimespec.tv_sec)
            
            return Date(timeIntervalSince1970: interval)
        }
    }
    
    private func hasFile(ofType type: String, at path: String) -> Bool {
        do {
            let contents = try fm.contentsOfDirectory(atPath: path)
            
            return contents.contains {
                $0.hasSuffix("." + type)
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
}
