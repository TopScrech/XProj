import SwiftUI

//Label("iOS", systemImage: "iphone")
//Label("macOS", systemImage: "macbook")
//Label("watchOS", systemImage: "applewatch")
//Label("tvOS", systemImage: "tv")
//Label("visionOS", systemImage: "vision.pro")
//Label("Widgets", systemImage: "widget.large")
//Label("iMessage", systemImage: "message.badge")
//Label("Tests", systemImage: "testtube.2")

enum NavCategory: String, Identifiable, Codable, Hashable, CaseIterable {
    var id: String {
        rawValue
    }
    
    case proj, package, vapor, workspace, playground, allItems, favorites, derivedData, packageDependencies, appStore, iOS, macOS, watchOS, tvOS, visionOS
    
    static var projTypes: [NavCategory] {[
        .proj,
        .package,
        .vapor,
        .workspace,
        .playground
    ]}

    static var projPlatforms: [NavCategory] {[
        .iOS,
        .macOS,
        .watchOS,
        .tvOS,
        .visionOS
    ]}

    var platformName: String? {
        switch self {
        case .iOS:      "iOS"
        case .macOS:    "macOS"
        case .watchOS:  "watchOS"
        case .tvOS:     "tvOS"
        case .visionOS: "visionOS"
        default:        nil
        }
    }
    
    var icon: String {
        switch self {
        case .proj:                "hammer.fill"
        case .workspace:           "hammer.fill"
        case .package:             "shippingbox.fill"
        case .packageDependencies: "shippingbox.fill"
        case .vapor:               "drop.fill"
        case .playground:          "swift"
        case .derivedData:         "folder.badge.gearshape"
        case .appStore:            "app"
        case .favorites:           "star.fill"
        case .iOS:                 "iphone"
        case .macOS:               "macbook"
        case .watchOS:             "applewatch"
        case .tvOS:                "tv"
        case .visionOS:            "vision.pro"
        default: ""
        }
    }
    
    var loc: LocalizedStringKey {
        switch self {
        case .allItems:            "All"
        case .package:             "Packages"
        case .playground:          "Playgrounds"
        case .proj:                "Projects"
        case .vapor:               "Vapor"
        case .workspace:           "Workspaces"
        case .derivedData:         "Derived Data"
        case .packageDependencies: "Package Dependencies"
        case .appStore:            "App Store"
        case .favorites:           "Favorites"
        case .iOS:                 "iOS"
        case .macOS:               "macOS"
        case .watchOS:             "watchOS"
        case .tvOS:                "tvOS"
        case .visionOS:            "visionOS"
        }
    }
}
