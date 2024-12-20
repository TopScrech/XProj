import SwiftUI
import XcodeProjKit

struct Project: Identifiable {
    let id = UUID()
    let name, path: String
    let type: ProjType
    let openedAt: Date
    let modifiedAt: Date?
    let createdAt: Date?
    let attributes: [FileAttributeKey: Any]
    
    var swiftToolsVersion: String? = nil
    var packages: [Package] = []
    var targets: [Target] = []
    var platforms: [String] = []
    
    init(
        name: String,
        path: String,
        type: ProjType,
        openedAt: Date,
        modifiedAt: Date?,
        createdAt: Date?,
        attributes: [FileAttributeKey : Any]
    ) {
        self.name = name
        self.path = path
        self.type = type
        self.openedAt = openedAt
        self.modifiedAt = modifiedAt
        self.createdAt = createdAt
        self.attributes = attributes
        
        self.swiftToolsVersion = fetchSwiftToolsVersion()
        self.packages = parseSwiftPackages()
        self.targets = fetchTargets()
        self.platforms = fetchUniquePlatforms()
    }
    
    var icon: String {
        switch type {
        case .proj:       "hammer.fill"
        case .workspace:  "hammer.fill"
        case .package:    "shippingbox.fill"
        case .playground: "swift"
        default:          "questionmark"
        }
    }
    
    var iconColor: Color {
        switch type {
        case .proj:       .blue
        case .workspace:  .white
        case .package:    .package
        case .playground: .blue
        default:          .gray
        }
    }
    
    func fetchUniquePlatforms() -> [String] {
        let allPlatforms = targets.flatMap {
            $0.deploymentTargets.keys
        }
        
        let uniquePlatforms = Array(Set(allPlatforms))
        
        return uniquePlatforms
    }
    
    func parseSwiftPackages() -> [Package] {
        switch type {
        case .proj:
            parsePackagesInProj()
            
        case .package:
            parsePackagesInPackage()
            
        case .vapor:
            parsePackagesInPackage()
            
            //        case .playground:
            
        default:
            []
        }
    }
    
    func parsePackagesInProj() -> [Package] {
        guard let url = fetchProjectFilePath(path) else {
            return []
        }
        
        do {
            let xcodeProj = try XcodeProj(url: url)
            let project = xcodeProj.project
            let packages = project.packageReferences
            
            let result = packages.compactMap { package in
                if let rep = package.repositoryURL,
                   let name = URL(string: rep)?.lastPathComponent {
                    return Package(
                        name: name,
                        repositoryUrl: rep,
                        requirementKind: package.requirement?.keys.first ?? "",
                        requirementParam: package.requirement?.values.first as? String ?? ""
                    )
                }
                
                return nil
            }
            
            return result
        } catch {
            return []
        }
    }
}
