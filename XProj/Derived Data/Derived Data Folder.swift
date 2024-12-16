import ScrechKit

struct DerivedDataFolder: Identifiable, Equatable {
    let id = UUID()
    
    let name: String
    let size: Int64
    
    var formattedSize: String {
        formatBytes(size)
    }
}
