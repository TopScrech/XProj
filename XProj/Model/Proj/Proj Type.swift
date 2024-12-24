import SwiftUI

enum ProjType: String, Identifiable, Codable, Hashable, CaseIterable {
    case proj,
         workspace,
         package,
         vapor,
         playground,
         derivedData,
         packageDependencies,
         allItems
    
    static var projTypes: [ProjType] {
        [.proj, .workspace, .package, .vapor, .playground]
    }
    
    var id: String {
        rawValue
    }
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .package: "Packages"
        case .playground: "Playgrounds"
        case .proj: "Projects"
        case .vapor: "Vapor"
        case .workspace: "Workspaces"
        case .derivedData: "Derived Data"
        case .packageDependencies: "Package Dependencies"
        case .allItems: "All Items"
        }
    }
}
