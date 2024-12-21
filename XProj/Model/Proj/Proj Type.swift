import SwiftUI

enum ProjType: String, Codable, Hashable, CaseIterable, Identifiable {
    case proj,
         workspace,
         package,
         vapor,
         playground,
         unknown
    
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
        case .unknown: "Unknown"
        }
    }
}
