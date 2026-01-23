import SwiftUI
import OSLog
import XcodeProjKit

struct Proj: Identifiable, Hashable, Codable {
    var id: String
    
    // Meta
    var name: String
    var path: String
    let type: NavCategory
    let openedAt: Date
    let modifiedAt: Date?
    let createdAt: Date?
    
    // Proj details
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
    }
    
    /// SF icon
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
    
    func fetchUniquePlatforms(_ targets: [Target]) -> [String] {
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
    
    /// Inducated whether a project has widget target(s)
    var hasWidgets: Bool {
        targets.contains {
            $0.type == .widgets
        }
    }
    
    /// Inducated whether a project has test target(s)
    var hasTests: Bool {
        targets.contains {
            $0.type == .uiTests || $0.type == .unitTests
        }
    }
    
    mutating func loadDetails() async {
        packages = parseSwiftPackages()
        
        let fetchedTargets = await fetchTargets()
        targets = fetchedTargets
        platforms = fetchUniquePlatforms(fetchedTargets)
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
    
    func parseSwiftPackages() -> [Package] {
        switch type {
        case .proj: parsePackagesInProj()
        case .package, .vapor: parsePackagesInPackage()
            //        case .playground:
        default: []
        }
    }
    
    private func parsePackagesInProj() -> [Package] {
        guard
            let url = fetchProjFilePath(path),
            let sanitizedURL = sanitizedXcodeProjURL(url)
        else {
            return []
        }
        
        do {
            let xcodeProj = try XcodeProj(url: sanitizedURL)
            let project = xcodeProj.project
            let packages = project.packageReferences
            
            return packages.compactMap { package in
                guard
                    let rep = package.repositoryURL,
                    let name = URL(string: rep)?.lastPathComponent
                else {
                    return nil
                }
                
                // requirementKind: package.requirement?.keys.first,
                // requirementParam: package.requirement?.values.first as? String
                return Package(name: name, repositoryURL: rep)
            }
        } catch {
            Logger().error("\(error)")
            return []
        }
    }
}

extension Proj {
    static var mock: Proj {
        DataModel.shared.projects[0]
    }
}
