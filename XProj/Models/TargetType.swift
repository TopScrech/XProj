import Foundation

enum TargetType: String, Identifiable, Codable, Hashable, CaseIterable {
    case app, widgets, iMessage, unitTests, uiTests, other
    
    var id: String {
        rawValue
    }
    
    //    case iOS, tvOS, watchOS, macOS, visionOS, widgets, iMessage
}
