import Foundation

extension Project {
    /// Fetches and returns Swift package dependencies as an array of `Package` structs
    ///
    /// - Returns: An array of `Package` structs with the name and repository URL
    func parsePackagesInPackage() -> [Package] {
        // URL for Package.resolved
        let folderURL = URL(fileURLWithPath: path, isDirectory: true)
        let packageResolvedURL = folderURL.appendingPathComponent("Package.resolved")
        
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: packageResolvedURL.path) else {
            return []
        }
        
        do {
            // Read Package.resolved
            let data = try Data(contentsOf: packageResolvedURL)
            
            // Parse JSON
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let pins = json["pins"] as? [[String: Any]] {
                
                var packages: [Package] = []
                
                for pin in pins {
                    if let name = pin["identity"] as? String,
                       let repositoryUrl = pin["location"] as? String {
                        packages.append(Package(
                            name: name,
                            repositoryUrl: repositoryUrl,
                            requirementKind: nil,
                            requirementParam: nil
                        ))
                    }
                }
                
                return packages
            } else {
                print("Error: Unable to parse 'Package.resolved' at \(packageResolvedURL)")
                return []
            }
        } catch {
            print("Error reading 'Package.resolved': \(error.localizedDescription)")
            return []
        }
    }
}
