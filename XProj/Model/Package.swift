import Foundation

struct Package: Identifiable, Hashable, Decodable {
    var id = UUID()
    
    /// The name of the Swift package
    let name: String
    
    /// The repository URL of the Swift package
    let repositoryUrl: String
    
    /// The kind of version requirement (e.g., branch, upToNextMajorVersion)
    let requirementKind: String?
    
    /// The parameter associated with the requirement kind (e.g., branch name or minimum version)
    let requirementParam: String?
    
    init(
        name: String,
        repositoryUrl: String,
        requirementKind: String? = nil,
        requirementParam: String? = nil
    ) {
        self.name = name
        self.repositoryUrl = repositoryUrl
        self.requirementKind = requirementKind
        self.requirementParam = requirementParam
    }
    
    var author: String? {
        // Attempt to create a URL object from the input string
        guard let url = URL(string: repositoryUrl) else {
            print("Invalid URL string")
            return nil
        }
        
        // Ensure the host is "github.com"
        guard url.host?.lowercased().contains("github.com") == true else {
            print("URL is not a GitHub repository")
            return nil
        }
        
        // Split the path into components
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        // GitHub repository URLs typically have the format: /author/repo
        guard pathComponents.count >= 2 else {
            print("URL does not contain enough path components")
            return nil
        }
        
        // The first component is the author
        let author = pathComponents[0]
        
        return author
    }
}
