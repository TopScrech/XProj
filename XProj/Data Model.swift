// An observable data model of projects and miscellaneous groupings

import SwiftUI

@Observable
final class DataModel {
    private(set) var projects: [Proj]
    
    private var projectsById: [Proj.ID: Proj] = [:]
    
    var searchPrompt = ""
    var projectsFolder = ""
    private let udKey = "projects_folder_bookmark"
    
    // The shared singleton data model object
    static let shared = {
        DataModel()
    }()
    
    init() {
        let vm = ProjListVM()
        
        let projects = vm.getFolders()
        projectsFolder = vm.projectsFolder
        
        projectsById = Dictionary(uniqueKeysWithValues: projects.map { proj in
            (proj.id, proj)
        })
        
        self.projects = projects
    }
    
    /// Accesses the project associated with the given unique identifier
    /// if the identifier is tracked by the data model; otherwise, returns `nil`
    subscript(projId: Proj.ID) -> Proj? {
        projectsById[projId]
    }
    
    var filteredProjects: [Proj] {
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
    
    var lastOpenedProjects: [Proj] {
        projects.filter {
            $0.type == .proj
        }
        .prefix(5).sorted {
            $0.openedAt > $1.openedAt
        }
    }
    
    func showPicker() {
        openFolderPicker { url in
            guard let url else {
                return
            }
            
            saveSecurityScopedBookmark(url, forKey: self.udKey) {
#warning("Refresh")
                //                self.getFolders()
            }
        }
    }
    
    /// The projects for a given category, sorted by name
    func projects(in type: NavCategory?) -> [Proj] {
        projects.filter {
            $0.type == type
        }
    }
    
    //    func projects(relatedTo proj: Proj) -> [Proj] {
    //        projects.filter {
    //            proj.related.contains($0.id)
    //        }
    //    }
    
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
    
    func findDuplicates() -> [[Proj]] {
        var nameTypeCountDict: [String: Int] = [:]
        var duplicates: [[Proj]] = []
        
        for proj in projects {
            let key = proj.name + "-" + proj.type.rawValue
            
            if let count = nameTypeCountDict[key] {
                nameTypeCountDict[key] = count + 1
            } else {
                nameTypeCountDict[key] = 1
            }
            
            if let count = nameTypeCountDict[key], count > 1 {
                let hasDuplicates = duplicates.contains(where: {
                    if let test = $0.first, test.name == proj.name && test.type == proj.type {
                        return true
                    }
                    
                    return false
                })
                
                if !hasDuplicates {
                    duplicates.append(projects.filter {
                        $0.name == proj.name && $0.type == proj.type
                    })
                }
            }
        }
        
        return duplicates
    }
    
    func openProj(_ proj: Proj) {
        let path = proj.path
        findProj(path)
    }
    
    func openProjects(_ selected: Set<Proj>) {
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
}
