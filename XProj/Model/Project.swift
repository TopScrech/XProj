import SwiftUI

struct Project: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let type: FileType
    let lastOpened: Date
    let attributes: [FileAttributeKey: Any]
    
    var icon: String {
        switch type {
        case .folder: "folder"
        case .proj: "hammer"
        case .unknown: "questionmark"
        }
    }
    
    var iconColor: Color {
        switch type {
        case .folder:  .yellow
        case .proj:    .blue
        case .unknown: .gray
        }
    }
}

enum FileType: String {
    case folder,
         proj,
         unknown
}
