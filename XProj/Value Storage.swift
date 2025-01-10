import SwiftUI

final class ValueStorage: ObservableObject {
    @AppStorage("show_proj_targets") var showProjTargets = true
    @AppStorage("show_proj_target_version") var showProjTargetVersion = false
    @AppStorage("show_proj_package_dependencies") var showProjPackageDependencies = true
    @AppStorage("show_proj_app_store_link") var showProjAppStoreLink = true
}
