import SwiftUI

struct Project: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let type: FileType
    let lastOpened: Date
    let attributes: [FileAttributeKey: Any]
    
    var icon: String {
        switch type {
        case .folder:  "folder"
        case .proj:    "hammer.fill"
        case .package: "shippingbox.fill"
        case .unknown: "questionmark"
        }
    }
    
    var iconColor: Color {
        switch type {
        case .folder:  .yellow
        case .proj:    .blue
        case .package: .package
        case .unknown: .gray
        }
    }
    
    // Implementing Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(path)
        hasher.combine(type)
        hasher.combine(lastOpened)
        
        // Convert attributes to a hashable form
        let attributeArray = attributes.map { ($0.key, $0.value) }
        for (key, value) in attributeArray {
            hasher.combine(key)
            // Use `AnyHashable` to hash the value
            if let hashableValue = value as? AnyHashable {
                hasher.combine(hashableValue)
            } else {
                // If value is not hashable, convert it to something that is hashable
                // or handle it based on your specific requirements
                fatalError("Non-hashable value found in attributes.")
            }
        }
    }
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.path == rhs.path &&
               lhs.type == rhs.type &&
               lhs.lastOpened == rhs.lastOpened &&
               lhs.attributesAreEqual(to: rhs.attributes)
    }
    
    private func attributesAreEqual(to otherAttributes: [FileAttributeKey: Any]) -> Bool {
        // Ensure attributes dictionaries are equal
        guard attributes.count == otherAttributes.count else {
            return false
        }
        
        for (key, value) in attributes {
            guard let otherValue = otherAttributes[key] else {
                return false
            }
            
            // Compare values if possible (assuming FileAttributeKey is Equatable)
            if let equatableValue = value as? AnyHashable,
               let otherEquatableValue = otherValue as? AnyHashable {
                if equatableValue != otherEquatableValue {
                    return false
                }
            } else {
                // Handle non-comparable values based on your specific requirements
                fatalError("Non-equatable value found in attributes.")
            }
        }
        
        return true
    }
}

enum FileType: String {
    case folder,
         proj,
         package,
         unknown
}
