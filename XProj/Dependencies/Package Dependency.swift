import Foundation

struct PackageDependency: Identifiable {
    let id = UUID()
    
    let package: Package
    let proj: [Project]
    
    var name: String {
        package.name
    }
    
    var useCount: Int {
        proj.count
    }
}
