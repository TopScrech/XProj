// An observable data model of recipes and miscellaneous groupings

import SwiftUI

@Observable
final class DataModel {
    private(set) var projects: [Proj]
    
    private var recipesById: [Proj.ID: Proj] = [:]
    
    // The shared singleton data model object
    static let shared = {
        DataModel()
    }()
        
    init() {
        let recipes = ProjListVMNew().getFolders()
        
        recipesById = Dictionary(uniqueKeysWithValues: recipes.map { recipe in
            (recipe.id, recipe)
        })
        
        self.projects = recipes.sorted {
            $0.name < $1.name
        }
    }
//    private static var dataURL: URL {
//        get throws {
//            let bundle = Bundle.main
//            
//            guard
//                let path = bundle.path(forResource: "Recipes", ofType: "json")
//            else {
//                throw CocoaError(.fileReadNoSuchFile)
//            }
//            
//            return URL(fileURLWithPath: path)
//        }
//    }
    
    /// The recipes for a given category, sorted by name
    func recipes(in type: ProjType?) -> [Proj] {
        projects
            .filter {
                $0.type == type
            }
    }
    
    //    /// The related recipes for a given recipe, sorted by name
    //    func recipes(relatedTo recipe: Recipe) -> [Recipe] {
    //        recipes.filter {
    //            recipe.related.contains($0.id)
    //        }
    //    }
    
    /// Accesses the recipe associated with the given unique identifier
    /// if the identifier is tracked by the data model; otherwise, returns `nil`
    subscript(recipeId: Proj.ID) -> Proj? {
        recipesById[recipeId]
    }
}

final class ProjListVMNew {
    private let fm = FileManager.default
    var searchPrompt = ""
    var projectsFolder = ""
    private let udKey = "projects_folder_bookmark"
    
    var projects: [Proj] = []
    
    func getFolders() -> [Proj] {
        let startTime = CFAbsoluteTimeGetCurrent()
        restoreAccessToFolderOld()
        projects = []
        
        guard let url = FolderAccessManager.shared.restoreAccessToFolder(udKey) else {
            print("Unable to restore access to the folder. Please select a new folder")
            return []
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
        
        return projects
    }
    
    private func processPath(_ path: String) throws {
        let projects = try fm.contentsOfDirectory(atPath: path)
        
        for proj in projects {
            try processProj(proj, at: path)
        }
    }
    
    private func processProj(_ proj: String, at path: String) throws {
        var name = proj
        
        let projPath = path + "/" + name
        let attributes = try fm.attributesOfItem(atPath: projPath)
        
        let typeAttribute = attributes[.type] as? String ?? "Other"
        
        if let isHidden = attributes[.extensionHidden] as? Bool, isHidden {
            return
        }
        
        if name == ".git" || name == ".build" {
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
            
        } else if name.contains(".playground") {
            fileType = .playground
            name = name.replacingOccurrences(of: ".playground", with: "")
            
        } else {
            fileType = .unknown
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
        
        projects.append(
            Proj(
                id: projPath,
                name: name,
                path: projPath,
                type: fileType,
                openedAt: openedAt,
                modifiedAt: modifiedAt,
                createdAt: createdAt
                //                attributes: attributes
            )
        )
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
    
    private func hasVapor( _ path: String) -> Bool {
        let resolvedPath = path + "/Package.resolved"
        
        guard fm.fileExists(atPath: resolvedPath) else {
            return false
        }
        
        let vaporUrl = "https://github.com/vapor/vapor.git"
        
        do {
            let fileContents = try String(contentsOfFile: resolvedPath, encoding: .utf8)
            
            let containsVapor = fileContents.contains(vaporUrl)
            
            return containsVapor
        } catch {
            return false
        }
    }
    
    private func restoreAccessToFolderOld() {
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
}
