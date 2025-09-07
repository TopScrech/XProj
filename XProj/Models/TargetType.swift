import Foundation

enum TargetType: String, Identifiable, Codable, Hashable, CaseIterable {
    //    case iOS, tvOS, watchOS, macOS, visionOS, widgets, iMessage
    var id: String {
        rawValue
    }
    
    case app,
         widgets,
         iMessage,
         unitTests,
         uiTests,
         other
}
