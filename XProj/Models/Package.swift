import Foundation
import OSLog

struct Package: Identifiable, Hashable, Codable {
    var id: String {
        repositoryURL
    }
    
    let name: String
    let repositoryURL: String
    let requirementKind: String?
    let requirementParam: String?
    
    init(
        name: String,
        repositoryURL: String,
        requirementKind: String? = nil,
        requirementParam: String? = nil
    ) {
        self.name = name
        self.repositoryURL = repositoryURL
        self.requirementKind = requirementKind
        self.requirementParam = requirementParam
    }
    
    var author: String? {
        // Attempt to create a URL object from the input string
        guard let url = URL(string: repositoryURL) else {
            Logger().error("Invalid URL string")
            return nil
        }
        
        // Ensure the host is Github
        guard url.host?.localizedStandardContains("github.com") == true else {
            Logger().error("URL is not a GitHub repo")
            return nil
        }
        
        let pathComponents = url.pathComponents.filter {
            $0 != "/"
        }
        
        // GitHub repository URLs typically have the format: /author/repo
        guard pathComponents.count >= 2 else {
            Logger().error("URL does not contain enough path components")
            return nil
        }
        
        return pathComponents[0] // author
    }
}
