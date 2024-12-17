import Foundation

struct PackageDependency: Identifiable {
    let id = UUID()
    
    let package: Package
    let projects: [Project]
    
    var sortedProjects: [Project] {
        projects.sorted {
            $0.openedAt > $1.openedAt
        }
    }
    
    var name: String {
        package.name
    }
    
    var useCount: Int {
        projects.count
    }
    
    var author: String? {
        package.author
    }
}
