import Foundation

extension Project: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(path)
        hasher.combine(type)
        hasher.combine(openedAt)
        
        let sortedAttributes = attributes.sorted { $0.key.rawValue < $1.key.rawValue }
        for (key, value) in sortedAttributes {
            hasher.combine(key.rawValue)
            if let hashableValue = value as? AnyHashable {
                hasher.combine(hashableValue)
            } else {
                // Handle non-hashable values as needed
                hasher.combine("\(value)")
            }
        }
    }
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.path == rhs.path &&
        lhs.type == rhs.type &&
        lhs.openedAt == rhs.openedAt &&
        lhs.attributesAreEqual(rhs.attributes)
    }
    
    private func attributesAreEqual(_ other: [FileAttributeKey: Any]) -> Bool {
        if attributes.count != other.count {
            return false
        }
        
        for (key, value) in attributes {
            if let otherValue = other[key] {
                if let hashableValue = value as? AnyHashable, let otherHashableValue = otherValue as? AnyHashable {
                    if hashableValue != otherHashableValue {
                        return false
                    }
                } else {
                    if "\(value)" != "\(otherValue)" {
                        return false
                    }
                }
            } else {
                return false
            }
        }
        
        return true
    }
}
