import SwiftUI

enum ProjType: String, Identifiable, Codable, Hashable, CaseIterable {
    case proj,
         workspace,
         package,
         vapor,
         playground
    
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
        }
    }
}
