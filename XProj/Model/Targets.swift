import Foundation
import XcodeProjKit

extension Project {
    func fetchTargets() -> [(target: PBXNativeTarget, bundleID: String?)] {
        guard type == .proj else {
            return []
        }
        
        do {
            let fileManager = FileManager.default
            let folderURL = URL(fileURLWithPath: path)
            
            // Find the .xcodeproj file in the folder
            guard let xcodeProjURL = try? fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).first(where: { $0.pathExtension == "xcodeproj" }) else {
                print("projectFileNotFound")
                return []
            }
            
            // Check if the .xcodeproj file exists
            guard fileManager.fileExists(atPath: xcodeProjURL.path) else {
                print("projectFileNotFound")
                return []
            }
            
            let xcodeProj = try XcodeProj(url: xcodeProjURL)
            
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
