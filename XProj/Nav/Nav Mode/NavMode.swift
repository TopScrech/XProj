import SwiftUI

enum NavMode: Int, Identifiable, CaseIterable, Codable {
    case twoColumn = 1, threeColumn = 2
    
    var id: Int {
        rawValue
    }
    
    var name: LocalizedStringKey {
        switch self {
        case .twoColumn: "Two columns"
        case .threeColumn: "Three columns"
        }
    }
    
    var icon: String {
        switch self {
        case .twoColumn: "sidebar.left"
        case .threeColumn: "rectangle.split.3x1"
        }
    }
}
