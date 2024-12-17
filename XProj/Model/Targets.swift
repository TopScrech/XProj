import Foundation
import XcodeProjKit

class Target: Identifiable {
    let id = UUID()
    
    let name: String
    let bundleId: String?
    var appStoreApp: AppStoreApp? = nil
    
    init(name: String, bundleId: String?) {
        self.name = name
        self.bundleId = bundleId
        
        Task {
            self.appStoreApp = await fetchAppStoreApp()
        }
    }
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
                
                return Target(
                    name: target.name,
                    bundleId: bundleID?.replacingOccurrences(of: ".debug", with: "")
                )
            }
            
            return targetObjects
        } catch {
            print(error)
            return []
        }
    }
}

extension PBXNativeTarget: @retroactive Identifiable {}
