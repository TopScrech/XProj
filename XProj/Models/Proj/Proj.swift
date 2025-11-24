// A data model for a recipe and its metadata, including its related projects

import SwiftUI
import XcodeProjKit

struct Proj: Identifiable, Hashable, Codable {
    var id: String
    
    var name: String
    var path: String
    let type: NavCategory
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
        type: NavCategory,
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
        //        self.packages          = parseSwiftPackages()
        //        self.targets           = fetchTargets()
        //        self.platforms         = fetchUniquePlatforms()
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
    
    private func fetchUniquePlatforms() -> [String] {
        targets
            .flatMap(\.deploymentTargets)
            .map {
                $0.components(separatedBy: " ").first ?? $0
            }
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
    
    func fetchRemoteRepositoryURL() -> String? {
        let gitFolderPath = (path as NSString).appendingPathComponent(".git/config")
        let configURL = URL(fileURLWithPath: gitFolderPath)
        
        guard let configContents = try? String(contentsOf: configURL) else {
            return nil
        }
        
        let lines = configContents.split(separator: "\n")
        var isInRemoteOriginSection = false
        
        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines) == "[remote \"origin\"]" {
                isInRemoteOriginSection = true
                
            } else if isInRemoteOriginSection, line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("url =") {
                return line.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacing("url =", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
            } else if line.hasPrefix("[") {
                isInRemoteOriginSection = false
            }
        }
        
        return nil
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
        guard let url = fetchProjFilePath(path) else {
            return []
        }
        
        do {
            let xcodeProj = try XcodeProj(url: url)
            let project = xcodeProj.project
            let packages = project.packageReferences
            
            return packages.compactMap { package in
                if let rep = package.repositoryURL,
                   let name = URL(string: rep)?.lastPathComponent {
                    return Package(name: name, repositoryUrl: rep)
                        //                        requirementKind: package.requirement?.keys.first,
                        //                        requirementParam: package.requirement?.values.first as? String
                }
                
                return nil
            }
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
