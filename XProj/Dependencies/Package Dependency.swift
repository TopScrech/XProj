import Foundation

struct PackageDependency: Identifiable {
    let id = UUID()
    
    let package: Package
    let projects: [Project]
    
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
