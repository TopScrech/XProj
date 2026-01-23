import ScrechKit
import OSLog

@Observable
final class DataModel {
    var projects: [Proj] = []
    
    private var projectsById: [Proj.ID: Proj] = [:]
    
    var searchPrompt = ""
    var projectsFolder = ""
    
    private let udKey = "projects_folder_bookmark"
    private let cacheKey = "projects_cache"
    
    @ObservationIgnored private var cachedPublishedProjects: [Proj] = []
    @ObservationIgnored private var isLoadingAppStoreProjects = false
    @ObservationIgnored private var didLoadAppStoreProjects = false
    @ObservationIgnored private var isLoadingPlatformProjects = false
    
    // Shared singleton data model object
    static let shared = {
        DataModel()
    }()
    
    init() {
        loadCachedProjects()
        refreshProjects()
    }
    
    var publishedProjects: [Proj] {
        cachedPublishedProjects
    }
    
    func loadAppStoreProjectsIfNeeded() async {
        let needsRefresh = projects.contains { proj in
            guard proj.type == .proj else {
                return false
            }
            
            if proj.targets.isEmpty {
                return true
            }
            
            return proj.targets.contains {
                $0.bundleId != nil && $0.appStoreApp == nil
            }
        }
        
        guard needsRefresh || !didLoadAppStoreProjects else {
            return
        }
        
        await loadAppStoreProjects()
    }
    
    func loadAppStoreProjects() async {
        guard !isLoadingAppStoreProjects else {
            return
        }
        
        isLoadingAppStoreProjects = true
        
        defer {
            isLoadingAppStoreProjects = false
            didLoadAppStoreProjects = true
        }
        
        let currentProjects = projects
        var updatedProjects = currentProjects
        var didUpdate = false
        
        for (index, proj) in currentProjects.enumerated() {
            guard proj.type == .proj else {
                continue
            }
            
            let needsTargetRefresh = proj.targets.isEmpty || proj.targets.contains {
                $0.bundleId != nil && $0.appStoreApp == nil
            }
            
            guard needsTargetRefresh else {
                continue
            }
            
            var updatedProj = proj
            await updatedProj.loadTargets()
            
            if updatedProj.targets != proj.targets {
                updatedProjects[index] = updatedProj
                didUpdate = true
            }
        }
        
        guard didUpdate else { return }
        
        updateProjects(updatedProjects)
        cacheProjects(updatedProjects)
    }
    
    func loadPlatformProjectsIfNeeded() async {
        guard !isLoadingPlatformProjects else {
            return
        }
        
        let needsRefresh = projects.contains { proj in
            guard proj.type == .proj else {
                return false
            }
            
            return proj.platforms.isEmpty
        }
        
        guard needsRefresh else { return }
        
        isLoadingPlatformProjects = true
        
        defer {
            isLoadingPlatformProjects = false
        }
        
        let currentProjects = projects
        var updatedProjects = currentProjects
        var didUpdate = false
        
        for (index, proj) in currentProjects.enumerated() {
            guard proj.type == .proj, proj.platforms.isEmpty else {
                continue
            }
            
            var updatedProj = proj
            await updatedProj.loadPlatforms()
            
            if updatedProj.platforms != proj.platforms || updatedProj.targets != proj.targets {
                updatedProjects[index] = updatedProj
                didUpdate = true
            }
        }
        
        guard didUpdate else { return }
        
        updateProjects(updatedProjects)
        cacheProjects(updatedProjects)
    }
    
    private func updateProjects(_ projects: [Proj]) {
        self.projects = projects
        
        self.projectsById = Dictionary(uniqueKeysWithValues: projects.map { proj in
            (proj.id, proj)
        })
        
        cachedPublishedProjects = projects.filter { proj in
            proj.targets.contains {
                $0.appStoreApp != nil
            }
        }
    }
    
    private func loadCachedProjects() {
        if let cachedData = UserDefaults.standard.data(forKey: cacheKey),
           let cachedProjects = try? JSONDecoder().decode([Proj].self, from: cachedData) {
            
            updateProjects(cachedProjects)
        }
    }
    
    private func restoreProjPath() -> String? {
        guard let url = BookmarkManager.restoreAccessToFolder(udKey) else {
            Logger().error("Unable to restore access to the folder. Please select a new folder")
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
        let fetchedProjects = vm.getFolders(folder)
        
        updateProjects(fetchedProjects)
        self.projectsFolder = folder
        
        didLoadAppStoreProjects = false
        isLoadingAppStoreProjects = false
        isLoadingPlatformProjects = false
        
        // Cache the fetched projects
        self.cacheProjects(fetchedProjects)
    }
    
    private func cacheProjects(_ projects: [Proj]) {
        if let data = try? JSONEncoder().encode(projects) {
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
                .localizedStandardContains(searchPrompt)
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
        BookmarkManager.openFolderPicker { url in
            guard let url else {
                return
            }
            
            BookmarkManager.saveSecurityScopedBookmark(url, forKey: self.udKey) {
                DispatchQueue.global(qos: .userInitiated).async {
                    Task { @MainActor in
                        self.refreshProjects()
                    }
                }
            }
        }
    }
    
    /// Projects for a given category, sorted by name
    func projects(in type: NavCategory?) -> [Proj] {
        guard let type else {
            return []
        }
        
        if let platform = type.platformName {
            return filteredProjects.filter {
                $0.platforms.contains(platform)
            }
        }
        
        return filteredProjects.filter {
            $0.type == type
        }
    }
    
    //    func projects(relatedTo proj: Proj) -> [Proj] {
    //        projects.filter {
    //            proj.related.contains($0.id)
    //        }
    //    }
    
    var swiftToolsVersions: String {
        let sortedArray = projects.compactMap {
            $0.swiftToolsVersion
        }.sorted()
        
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
                let hasDuplicates = duplicates.contains {
                    if let test = $0.first, test.name == proj.name && test.type == proj.type {
                        return true
                    }
                    
                    return false
                }
                
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
        findProj(proj.path)
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
