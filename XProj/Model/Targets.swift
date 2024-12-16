import Foundation
import XcodeProjKit

struct Target: Identifiable {
    let id = UUID()
    
    let name: String
    let bundleId: String?
}

extension Project {
    func fetchTargets() -> [Target] {
        guard
            type == .proj,
            let url = fetchProjectFilePath(path)
        else {
            return []
        }
        
        do {
            let xcodeProj = try XcodeProj(url: url)
            let project = xcodeProj.project
            let targets = project.targets
            
            // Map targets to `Target` objects
            let targetObjects: [Target] = targets.map { target in
                let bundleID = target.buildConfigurationList?.buildConfigurations.first?.buildSettings?["PRODUCT_BUNDLE_IDENTIFIER"] as? String
                return Target(name: target.name, bundleId: bundleID)
            }
            
            return targetObjects
        } catch {
            print(error)
            return []
        }
    }
}

extension PBXNativeTarget: @retroactive Identifiable {}
