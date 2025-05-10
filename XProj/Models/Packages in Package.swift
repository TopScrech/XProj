import Foundation

extension Proj {
    /// Fetches and returns Swift package dependencies as an array of `Package` structs
    ///
    /// - Returns: An array of `Package` structs with the name and repository URL
    func parsePackagesInPackage() -> [Package] {
        // URL for Package.resolved
        let folderUrl = URL(fileURLWithPath: path, isDirectory: true)
        let packageResolvedUrl = folderUrl.appendingPathComponent("Package.resolved")
        
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: packageResolvedUrl.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: packageResolvedUrl)
            let decoded = try JSONDecoder().decode(Root.self, from: data)
            
            return decoded.pins.map {
                Package(
                    name: $0.identity,
                    repositoryUrl: $0.location,
                    requirementKind: nil,
                    requirementParam: nil
                )
            }
        } catch {
            print("Error reading 'Package.resolved' at \(packageResolvedUrl):", error.localizedDescription)
            return []
        }
    }
}

fileprivate struct Root: Decodable {
    let version: Int
    let pins: [Pin]
    
    struct ObjectContainer: Decodable {
        let pins: [PinV1]
    }
    
    enum CodingKeys: String, CodingKey {
        case version, object, pins
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        
        if version == 2 || version == 3 {
            pins = try container.decode([Pin].self, forKey: .pins)
        } else {
            let objectContainer = try container.decode(ObjectContainer.self, forKey: .object)
            
            pins = objectContainer.pins.map {
                Pin(identity: $0.package, location: $0.repositoryURL)
            }
        }
    }
}

fileprivate struct Pin: Decodable {
    let identity: String
    let location: String
}

fileprivate struct PinV1: Decodable {
    let package: String
    let repositoryURL: String
}
