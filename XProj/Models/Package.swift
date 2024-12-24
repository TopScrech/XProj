import Foundation

struct Package: Identifiable, Hashable, Decodable {
    var id: String
    
    /// The name of the Swift package
    let name: String
    
    /// The repository URL of the Swift package
    let repositoryUrl: String
    
    /// The kind of version requirement (e.g., branch, upToNextMajorVersion)
    let requirementKind: String?
    
    /// The parameter associated with the requirement kind (e.g., branch name or minimum version)
    let requirementParam: String?
    
    init(
        id: String,
        name: String,
        repositoryUrl: String,
        requirementKind: String? = nil,
        requirementParam: String? = nil
    ) {
        self.id = id
        self.name = name
        self.repositoryUrl = repositoryUrl
        self.requirementKind = requirementKind
        self.requirementParam = requirementParam
    }
    
#warning("Requirement kind and param are disabled to fix navigation issues")
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        id = try container.decode(String.self, forKey: .id)
//        name = try container.decode(String.self, forKey: .name)
//        repositoryUrl = try container.decode(String.self, forKey: .repositoryUrl)
//        requirementKind = try container.decodeIfPresent(String.self, forKey: .requirementKind)
//        requirementParam = try container.decodeIfPresent(String.self, forKey: .requirementParam)
//    }
//    
//    private enum CodingKeys: String, CodingKey {
//        case id,
//             name,
//             repositoryUrl,
//             requirementKind,
//             requirementParam
//    }
    
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
        let pathComponents = url.pathComponents.filter {
            $0 != "/"
        }
        
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
