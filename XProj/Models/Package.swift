import Foundation

struct Package: Identifiable, Hashable, Decodable {
    var id: String {
        repositoryUrl
    }
    
    let name: String
    let repositoryUrl: String
    let requirementKind: String?
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
    
#warning("Requirement kind and param are disabled to fix navigation issues")
    
    var author: String? {
        // Attempt to create a URL object from the input string
        guard let url = URL(string: repositoryUrl) else {
            print("Invalid URL string")
            return nil
        }
        
        // Ensure the host is Github
        guard url.host?.lowercased().contains("github.com") == true else {
            print("URL is not a GitHub repository")
            return nil
        }
        
        let pathComponents = url.pathComponents.filter {
            $0 != "/"
        }
        
        // GitHub repository URLs typically have the format: /author/repo
        guard pathComponents.count >= 2 else {
            print("URL does not contain enough path components")
            return nil
        }
        
        let author = pathComponents[0]
        
        return author
    }
}
