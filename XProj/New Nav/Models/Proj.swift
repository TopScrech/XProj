// A data model for a recipe and its metadata, including its related projects

import SwiftUI
import XcodeProjKit

struct Proj: Identifiable, Hashable, Decodable {
    var id: String
    
    var name: String
    var path: String
    let type: ProjType
    let openedAt: Date
    let modifiedAt: Date?
    let createdAt: Date?
    
    var swiftToolsVersion: String? = nil
    var packages: [Package] = []
    var targets: [Target] = []
    var platforms: [String] = []
    
    init(
        id: String,
        name: String,
        path: String,
        type: ProjType,
        openedAt: Date,
        modifiedAt: Date?,
        createdAt: Date?
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.type = type
        self.openedAt = openedAt
        self.modifiedAt = modifiedAt
        self.createdAt = createdAt
        
        self.swiftToolsVersion = fetchSwiftToolsVersion()
        self.packages = parseSwiftPackages()
        self.targets = fetchTargets()
        self.platforms = fetchUniquePlatforms()
    }
    
    //    init(from decoder: Decoder) throws {
    //        let container = try decoder.container(keyedBy: CodingKeys.self)
    //
    //        id = try container.decode(String.self, forKey: .id)
    //        name = try container.decode(String.self, forKey: .name)
    //        path = try container.decode(String.self, forKey: .path)
    //        type = try container.decode(ProjType.self, forKey: .type)
    //
    //        openedAt = try container.decode(Date.self, forKey: .openedAt)
    //        modifiedAt = try container.decodeIfPresent(Date.self, forKey: .modifiedAt)
    //        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    //        packages = try container.decode([Package].self, forKey: .packages)
    //
    //        //        ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
    //
    //        //        let relatedIdStrings = try container.decode([String].self, forKey: .related)
    //
    //        //        related = relatedIdStrings.compactMap(UUID.init(uuidString:))
    //    }
    //
    //    private enum CodingKeys: String, CodingKey {
    //        case id,
    //             name,
    //             path,
    //             type,
    //             openedAt,
    //             modifiedAt,
    //             createdAt,
    //             packages
    //    }
    
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
    
    private func fetchUniquePlatforms() -> [String] {
        targets
            .flatMap(\.deploymentTargets)
            .map { $0.components(separatedBy: " ").first ?? $0 }
            .reduce(into: []) { result, platform in
                if !result.contains(platform) {
                    result.append(platform)
                }
            }
    }
    
    var hasImessage: Bool {
        targets.contains {
            $0.type == .iMessage
        }
    }
    
    var hasWidgets: Bool {
        targets.contains {
            $0.type == .widgets
        }
    }
    
    var hasTests: Bool {
        targets.contains {
            $0.type == .uiTests || $0.type == .unitTests
        }
    }
    
    private func parseSwiftPackages() -> [Package] {
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
    
    private func parsePackagesInProj() -> [Package] {
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
                        id: rep,
                        name: name,
                        repositoryUrl: rep,
                        requirementKind: nil,
                        //                        requirementKind: package.requirement?.keys.first,
                        requirementParam: nil
                        //                        requirementParam: package.requirement?.values.first as? String
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

extension Proj {
    static var mock: Proj {
        DataModel.shared.projects[0]
    }
}
