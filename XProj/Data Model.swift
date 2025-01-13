// An observable data model of projects and miscellaneous groupings

import ScrechKit

@Observable
final class DataModel {
    private(set) var projects: [Proj] = []
    
    private var projectsById: [Proj.ID: Proj] = [:]
    
    var searchPrompt = ""
    var projectsFolder = ""
    private let udKey = "projects_folder_bookmark"
    private let cacheKey = "projects_cache"
    
    // Shared singleton data model object
    static let shared = {
        DataModel()
    }()
    
    init() {
        loadCachedProjects()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.refreshProjects()
        }
    }
    
    private func loadCachedProjects() {
        if let cachedData = UserDefaults.standard.data(forKey: cacheKey),
           let cachedCodableProjects = try? JSONDecoder().decode([CodableProj].self, from: cachedData) {
            let cachedProjects = cachedCodableProjects.map {
                Proj(from: $0)
            }
            
            main {
                self.projects = cachedProjects
                
                self.projectsById = Dictionary(uniqueKeysWithValues: cachedProjects.map { proj in
                    (proj.id, proj)
                })
            }
        }
    }
    
    private func restoreProjPath() -> String? {
        guard let url = restoreAccessToFolder(udKey) else {
            print("Unable to restore access to the folder. Please select a new folder")
            return nil
        }
        
        return url.path
    }
    
    private func refreshProjects() {
        guard let folder = restoreProjPath() else {
            return
        }
        
        projectsFolder = folder
        
        let vm = ProjListVM()
        let projects = vm.getFolders(folder)
        
        main {
            self.projects = projects
            self.projectsFolder = folder
            
            self.projectsById = Dictionary(uniqueKeysWithValues: projects.map { proj in
                (proj.id, proj)
            })
            
            // Cache the fetched projects
            self.cacheProjects(projects)
        }
    }
    
    private func cacheProjects(_ projects: [Proj]) {
        let codableProjects = projects.map {
            $0.toCodable()
        }
        
        if let data = try? JSONEncoder().encode(codableProjects) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
    
    /// Accesses the project associated with the given unique id
    /// if the id is tracked by the data model; otherwise, returns `nil`
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
            $0.name
                .lowercased()
                .contains(searchPrompt.lowercased())
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
    
    /// Projects for a given category, sorted by name
    func projects(in type: NavCategory?) -> [Proj] {
        filteredProjects.filter {
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
