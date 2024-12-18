import Foundation
import XcodeProjKit

class Target: Identifiable {
    let id = UUID()
    
    let name: String
    let bundleId: String?
    let deploymentTargets: [String: String]
    let type: TargetType?
    var appStoreApp: AppStoreApp? = nil
    
    init(
        name: String,
        bundleId: String?,
        type: TargetType? = nil,
        deploymentTargets: [String: String] = [:]
    ) {
        self.name = name
        self.bundleId = bundleId
        self.type = type
        self.deploymentTargets = deploymentTargets
        
        Task {
            self.appStoreApp = await fetchAppStoreApp()
        }
    }
}

enum TargetType: String {
    //    case iOS, tvOS, watchOS, macOS, visionOS, widgets, iMessage
    case app,
         widgets,
         iMessage,
         unitTests,
         uiTests,
         other
}

func determineType(_ name: String, _ buildSettings: [String: Any]?) -> (type: TargetType, versions: [String: String])? {
    guard let buildSettings else {
        return nil
    }
    
    var type: TargetType = .other
    var configs: [String: String] = [:]
    
    if let iOS = buildSettings["IPHONEOS_DEPLOYMENT_TARGET"] as? String {
        configs["iOS"] = iOS
        type = .app
    }
    
    if let macOS = buildSettings["MACOSX_DEPLOYMENT_TARGET"] as? String {
        configs["macOS"] = macOS
        type = .app
    }
    
    if let tvOS = buildSettings["TVOS_DEPLOYMENT_TARGET"] as? String {
        configs["tvOS"] = tvOS
        type = .app
    }
    
    if let watchOS = buildSettings["WATCHOS_DEPLOYMENT_TARGET"] as? String {
        configs["watchOS"] = watchOS
        type = .app
    }
    
    if let visionOS = buildSettings["XROS_DEPLOYMENT_TARGET"] as? String {
        configs["visionOS"] = visionOS
        type = .app
    }
    
    switch name {
    case "Widgets Extension":
        configs["widgets"] = ""
        type = .widgets
        
    case "iMessage Extension":
        configs["iMessage"] = ""
        type = .iMessage
        
    case "Unit Tests":
        type = .unitTests
        
    case "UI Tests":
        type = .uiTests
        
    default:
        type = .app
        break
    }
    
    return (type, configs)
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
            
            let targetObjects: [Target] = targets.flatMap { target in
                let buildConfigs = target.buildConfigurationList?.buildConfigurations ?? []
                
                return buildConfigs.compactMap { buildConfig in
                    let targetName = target.name
                    let buildSettings = buildConfig.buildSettings
                    
                    let bundleID = buildSettings?["PRODUCT_BUNDLE_IDENTIFIER"] as? String
                    
                    if let test = determineType(targetName, buildSettings) {
                        return Target(
                            name: targetName,
                            bundleId: bundleID,
                            type: test.type,
                            deploymentTargets: test.versions
                        )
                    } else {
                        return Target(
                            name: targetName,
                            bundleId: bundleID
                        )
                    }
                }
            }
            
            return targetObjects
        } catch {
            print(error)
            return []
        }
    }
}

extension PBXNativeTarget: @retroactive Identifiable {}
