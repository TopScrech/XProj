import ScrechKit

struct DerivedDataFolder: Identifiable, Equatable {
    var id: String {
        name
    }
    
    let name: String
    let size: Int64
    
    var formattedSize: String {
        formatBytes(size)
    }
}
