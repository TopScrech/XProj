import Foundation
import XcodeProjKit

struct Target: Identifiable, Hashable, Decodable {
    var id: String
    
    let name: String
    let bundleId: String?
    let deploymentTargets: [String]
    let type: TargetType?
    var appStoreApp: AppStoreApp?
    
    init(
        id: String,
        name: String,
        bundleId: String?,
        type: TargetType? = nil,
        deploymentTargets: [String],
        appStoreApp: AppStoreApp?
    ) {
        self.id = id
        self.name = name
        self.bundleId = bundleId
        self.type = type
        self.deploymentTargets = deploymentTargets
        self.appStoreApp = appStoreApp
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
            let targets = xcodeProj.project.targets
            
            let targetObjects: [Target] = targets.flatMap { target in
                let buildConfigs = target.buildConfigurationList?.buildConfigurations ?? []
                
                var seenRefs = Set<String>()
                
                return buildConfigs.compactMap { buildConfig -> Target? in
                    let targetName = target.name
                    let buildSettings = buildConfig.buildSettings
                    let bundleId = buildSettings?["PRODUCT_BUNDLE_IDENTIFIER"] as? String
                    let id = target.ref
                    
                    guard !seenRefs.contains(target.ref) else {
                        return nil
                    }
                    
                    seenRefs.insert(target.ref)
                    
                    let type = determineType(targetName, buildSettings)
                    
                    var appStoreApp: AppStoreApp?
                    let semaphore = DispatchSemaphore(value: 0)
                    
                    Task {
                        appStoreApp = await fetchAppStoreApp(bundleId)
                        semaphore.signal()
                    }
                    
                    semaphore.wait()
                    
                    return Target(
                        id: id,
                        name: targetName,
                        bundleId: bundleId,
                        type: type.type,
                        deploymentTargets: type.versions,
                        appStoreApp: appStoreApp
                    )
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

func determineType(_ name: String, _ buildSettings: [String: Any]?) -> (type: TargetType, versions: [String]) {
    guard let buildSettings else {
        return (.other, [])
    }
    
    var type: TargetType = .other
    var configs: [String] = []
    
    if let iOS = buildSettings["IPHONEOS_DEPLOYMENT_TARGET"] as? String {
        configs.append("iOS \(iOS)")
        type = .app
    }
    
    if let macOS = buildSettings["MACOSX_DEPLOYMENT_TARGET"] as? String {
        configs.append("macOS \(macOS)")
        type = .app
    }
    
    if let tvOS = buildSettings["TVOS_DEPLOYMENT_TARGET"] as? String {
        configs.append("tvOS \(tvOS)")
        type = .app
    }
    
    if let watchOS = buildSettings["WATCHOS_DEPLOYMENT_TARGET"] as? String {
        configs.append("watchOS \(watchOS)")
        type = .app
    }
    
    if let visionOS = buildSettings["XROS_DEPLOYMENT_TARGET"] as? String {
        configs.append("visionOS \(visionOS)")
        type = .app
    }
    
    switch name {
    case "Widgets Extension":
        type = .widgets
        
    case "iMessage Extension":
        type = .iMessage
        
    case "Unit Tests":
        type = .unitTests
        
    case "UI Tests":
        type = .uiTests
        
    default:
        break
    }
    
    return (type, configs)
}
