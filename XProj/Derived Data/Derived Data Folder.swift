import ScrechKit

struct DerivedDataFolder: Identifiable, Equatable {
    var id: String {
        name
    }
    
    let name: String
    let size: Int64
    
    var formattedName: String {
        if name.contains("-") {
            name.split(separator: "-").dropLast().joined(separator: "-")
        } else {
            name
        }
    }
    
    var formattedSize: String {
        formatBytes(size)
    }
}
