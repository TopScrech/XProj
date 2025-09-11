import Foundation

struct FileLines: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let lines: Int
    
    var path: String {
        url.path
    }
}
