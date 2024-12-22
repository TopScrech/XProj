import Foundation
import XcodeProjKit

struct Target: Identifiable, Hashable, Decodable {
    var id: String
    
    let name: String
    let bundleId: String?
    let deploymentTargets: [String: String]
    let type: TargetType?
    var appStoreApp: AppStoreApp? = nil
    
    init(
        id: String,
        name: String,
        bundleId: String?,
        type: TargetType? = nil,
        deploymentTargets: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.bundleId = bundleId
        self.type = type
        self.deploymentTargets = deploymentTargets
        
#warning("appStoreApp")
        //        Task {
        //            self.appStoreApp = await fetchAppStoreApp()
        //        }
    }
}

enum TargetType: String, Identifiable, Codable, Hashable, CaseIterable {
    //    case iOS, tvOS, watchOS, macOS, visionOS, widgets, iMessage
    var id: String {
        rawValue
    }
    
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

extension Proj {
//    func isDebugConfiguration(_ buildSettings: [String: Any]?) -> Bool {
//        guard let buildSettings else {
//            return false
//        }
//        
//        if let activeConditions = buildSettings["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] as? String {
//            return activeConditions.contains("DEBUG")
//        }
//        
//        return false
//    }
    
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
                
                var seenRefs = Set<String>()
                
                return buildConfigs.compactMap { buildConfig -> Target? in
                    let targetName = target.name
                    let buildSettings = buildConfig.buildSettings
                    let bundleID = buildSettings?["PRODUCT_BUNDLE_IDENTIFIER"] as? String
                    let id = target.ref
//                    guard isDebugConfiguration(buildSettings) else {
//                        return nil
//                    }
                    guard !seenRefs.contains(target.ref) else {
                        return nil
                    }
                    
                    seenRefs.insert(target.ref)
                    
                    if let test = determineType(targetName, buildSettings) {
                        return Target(
                            id: id,
                            name: targetName,
                            bundleId: bundleID,
                            type: test.type,
                            deploymentTargets: test.versions
                        )
                    } else {
                        return Target(
                            id: id,
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
