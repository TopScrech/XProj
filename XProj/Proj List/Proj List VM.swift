import SwiftUI

@Observable
final class ProjListVM {
#warning("Make private")
    var projects: [Project] = []
    var searchPrompt = ""
    var projectsFolder = ""
    //    var isProcessing = false
    
    private let udKey = "projects_folder_bookmark"
    private let fm = FileManager.default
    
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
    
    var vaporCount: Int {
        projects.filter {
            $0.type == .vapor
        }.count
    }
    
    var filteredProjects: [Project] {
        if searchPrompt.isEmpty {
            projects
                .sorted {
                    $0.openedAt > $1.openedAt
                }
        } else {
            projects.filter {
                $0.name.lowercased().contains(searchPrompt.lowercased())
            }
            .sorted {
                $0.openedAt < $1.openedAt
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
            $0.openedAt > $1.openedAt
        }
    }
    
    func getFolders() {
        //        DispatchQueue.main.async {
        //            self.isProcessing = true
        //        }
        
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
            
            //            DispatchQueue.main.async {
            //                self.isProcessing = false
            //            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func processPath(_ path: String) throws {
        let projects = try fm.contentsOfDirectory(atPath: path)
        
        for proj in projects {
            try processProj(path: path, proj: proj)
        }
    }
    
    func processProj(path: String, proj: String) throws {
        let projPath = "\(path)/\(proj)"
        let attributes = try fm.attributesOfItem(atPath: projPath)
        
        let typeAttribute = attributes[.type] as? String ?? "Other"
        
        if let isHidden = attributes[.extensionHidden] as? Bool, isHidden {
            return
        }
        
        if proj == ".git" || proj == ".build" || proj == "Not Xcode" {
            return
        }
        
        let fileType: ProjType
        
        if hasXcodeProj(projPath) {
            fileType = .proj
            
        } else if hasSwiftPackage(projPath) {
            if isVapor(proj, path) {
                fileType = .vapor
            } else {
                fileType = .package
            }
            
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
            .init(
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
    
    func isVapor(_ name: String, _ path: String) -> Bool {
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: path) else {
            return false
        }
        
        do {
            let fileContents = try String(contentsOfFile: path + "/\(name)" + "/Package.resolved", encoding: .utf8)
            
            let vaporURL = "https://github.com/vapor/vapor.git"
            
            let containsVapor = fileContents.contains(vaporURL)
            
            return containsVapor
        } catch {
            return false
        }
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
    
#warning("Used twice")
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
