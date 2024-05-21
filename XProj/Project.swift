import SwiftUI

struct Project: Identifiable {
    let id = UUID()
    let name: String
    let type: ProjectType
    let typ: String
    let attributes: [FileAttributeKey: Any]
    
    var icon: String {
        switch type {
        case .project: "hammer.fill"
        case .spm: "questionmark"
        case .other: "questionmark"
        }
    }
    
    var iconColor: Color {
        switch type {
        case .project: .blue
        case .spm: .cyan
        case .other: .yellow
        }
    }
}

enum ProjectType {
    case project,
         spm,
         other
}
