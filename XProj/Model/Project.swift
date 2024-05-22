import SwiftUI

struct Project: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let attributes: [FileAttributeKey: Any]
    
    var icon: String {
        switch type {
        case "NSFileTypeDirectory": "hammer.fill"
        default: "questionmark"
        }
    }
    
    var iconColor: Color {
        switch type {
        case "NSFileTypeDirectory": .blue
        default: .gray
        }
    }
}
