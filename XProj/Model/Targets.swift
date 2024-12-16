import Foundation
import XcodeProjKit

extension Project {
    func fetchTargets() -> [(target: PBXNativeTarget, bundleID: String?)] {
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
            
            // Fetch the bundle ID for each target
            let targetsWithBundleIDs = targets.map { target in
                let bundleID = target.buildConfigurationList?.buildConfigurations.first?.buildSettings?["PRODUCT_BUNDLE_IDENTIFIER"] as? String
                return (target, bundleID)
            }
            
            return targetsWithBundleIDs
        } catch {
            print(error)
            return []
        }
    }
}

extension PBXNativeTarget: @retroactive Identifiable {}
