import SwiftUI

final class ValueStore: ObservableObject {
    @AppStorage("nav_mode")                       var navMode: NavMode?
    
    @AppStorage("sort_dependencies_by_author")    var sortByAuthor = true
    
    // Proj Details
    @AppStorage("show_proj_targets")              var showProjTargets = true
    @AppStorage("show_proj_target_version")       var showProjTargetVersion = false
    @AppStorage("show_proj_package_dependencies") var showProjPackageDependencies = true
    @AppStorage("show_proj_app_store_link")       var showProjAppStoreLink = true
    @AppStorage("show_proj_code_lines")           var showProjCodeLines = true
    @AppStorage("show_gitignore")                 var showGitignore = true
    
    @AppStorage("code_line_counting_extensions")
    var codeLineCountingExtensions = "swift, h, metal, py, cs, ts, js, json, xml, html, css, md"
}
