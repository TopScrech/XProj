import Foundation
import OSLog
import XcodeProjKit

struct Target: Identifiable, Hashable, Codable {
    var id: String
    
    let name: String
    let bundleId: String?
    let deploymentTargets: [String]
    let type: TargetType?
    var appStoreApp: AppStoreApp?
    let version: String?
    let build: String?
    
    init(
        id: String,
        name: String,
        bundleId: String?,
        type: TargetType? = nil,
        deploymentTargets: [String],
        appStoreApp: AppStoreApp?,
        version: String?,
        build: String?
    ) {
        self.id = id
        self.name = name
        self.bundleId = bundleId
        self.type = type
        self.deploymentTargets = deploymentTargets
        self.appStoreApp = appStoreApp
        self.version = version
        self.build = build
    }
}

extension Proj {
    func fetchTargets(includeAppStore: Bool = true) async -> [Target] {
        guard
            type == .proj,
            let url = fetchProjFilePath(path),
            let sanitizedURL = sanitizedXcodeProjURL(url)
        else {
            return []
        }
        
        do {
            let targets = try XcodeProj(url: sanitizedURL).project.targets
            var targetObjects: [Target] = []
            targetObjects.reserveCapacity(targets.count)
            
            for target in targets {
                let targetName = target.name
                if targetName.localizedCaseInsensitiveContains(".debug") {
                    continue
                }
                
                let buildConfigs = target.buildConfigurationList?.buildConfigurations ?? []
                let releaseBuildConfigs = buildConfigs.filter { buildConfig in
                    if buildConfig.name?.localizedCaseInsensitiveContains(".debug") == true {
                        return false
                    }
                    
                    if let bundleId = buildConfig.buildSettings?["PRODUCT_BUNDLE_IDENTIFIER"] as? String {
                        return !bundleId.localizedCaseInsensitiveContains(".debug")
                    }
                    
                    return true
                }
                
                if releaseBuildConfigs.isEmpty {
                    continue
                }
                
                let buildSettingsList = releaseBuildConfigs.map { $0.buildSettings ?? [:] }
                
                let bundleId = buildSettingsList.compactMap {
                    $0["PRODUCT_BUNDLE_IDENTIFIER"] as? String
                }.first
                
                let version = buildSettingsList.compactMap {
                    $0["MARKETING_VERSION"] as? String
                }.first
                
                let build = buildSettingsList.compactMap {
                    $0["CURRENT_PROJECT_VERSION"] as? String
                }.first
                
                var deploymentTargets: [String] = []
                var resolvedType: TargetType = .other
                
                if buildSettingsList.isEmpty {
                    let info = determineType(targetName, [:])
                    resolvedType = info.type
                    deploymentTargets = info.versions
                } else {
                    for buildSettings in buildSettingsList {
                        let info = determineType(targetName, buildSettings)
                        deploymentTargets.append(contentsOf: info.versions)
                        
                        if resolvedType == TargetType.other {
                            resolvedType = info.type
                        } else if info.type != TargetType.app && info.type != TargetType.other {
                            resolvedType = info.type
                        }
                    }
                }
                
                deploymentTargets = deploymentTargets.reduce(into: []) { result, platform in
                    if !result.contains(platform) {
                        result.append(platform)
                    }
                }
                
                let appStoreApp = includeAppStore ? await fetchAppStoreApp(bundleId) : nil
                
                targetObjects.append(Target(
                    id: target.ref,
                    name: targetName,
                    bundleId: bundleId,
                    type: resolvedType,
                    deploymentTargets: deploymentTargets,
                    appStoreApp: appStoreApp,
                    version: version,
                    build: build
                ))
            }
            
            return targetObjects
        } catch {
            Logger().error("\(error)")
            return []
        }
    }
    
    func determineType(_ name: String, _ buildSettings: [String: Any]?) -> (type: TargetType, versions: [String]) {
        let buildSettings = buildSettings ?? [:]
        
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
        case "Widgets Extension":  type = .widgets
        case "iMessage Extension": type = .iMessage
        case "Unit Tests":         type = .unitTests
        case "UI Tests":           type = .uiTests
        default:                   break
        }
        
        return (type, configs)
    }
}

extension PBXNativeTarget: @retroactive Identifiable {}
