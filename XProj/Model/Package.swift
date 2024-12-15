import Foundation

struct Package: Identifiable {
    let id = UUID()
    
    /// The name of the Swift package.
    let name: String
    
    /// The repository URL of the Swift package.
    let repositoryURL: String
    
    /// The kind of version requirement (e.g., branch, upToNextMajorVersion).
    let requirementKind: String
    
    /// The parameter associated with the requirement kind (e.g., branch name or minimum version).
    let requirementParam: String
}
