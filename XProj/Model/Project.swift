import SwiftUI

struct Project: Identifiable, Hashable {
    let id = UUID()
    let name, path: String
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
    
    // Hashable conformance
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
                fatalError("Non-hashable value found in attributes")
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
            
            // Compare values if possible
            if let equatableValue = value as? AnyHashable,
               let otherEquatableValue = otherValue as? AnyHashable {
                if equatableValue != otherEquatableValue {
                    return false
                }
            } else {
                // Handle non-comparable values based on your specific requirements
                fatalError("Non-equatable value found in attributes")
            }
        }
        
        return true
    }
    
    func projIcon() -> String? {
        let fileManager = FileManager.default
        let projectURL = URL(fileURLWithPath: path)
        
        var isDir: ObjCBool = false
        
        guard
            fileManager.fileExists(atPath: projectURL.path, isDirectory: &isDir),
            isDir.boolValue
        else {
            print("Error: The path '\(projectURL.path)' does not exist or is not a directory.")
            return nil
        }
        
        // Use FileManager's enumerator to traverse the directory recursively
        guard let enumerator = fileManager.enumerator(at: projectURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            print("Error: Unable to enumerate the project directory.")
            return nil
        }
        
        // Traverse through the enumerator to find Assets.xcassets directories
        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent == "Assets.xcassets",
               (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                
                // Now search for AppIcon.appiconset within this Assets.xcassets
                guard let appIconEnumerator = fileManager.enumerator(at: fileURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
                    print("Error: Unable to enumerate \(fileURL.path).")
                    continue
                }
                
                for case let appIconURL as URL in appIconEnumerator {
                    if appIconURL.lastPathComponent == "AppIcon.appiconset",
                       (try? appIconURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                        
                        // List files in AppIcon.appiconset & apply filter
                        do {
                            let fileURLs = try fileManager.contentsOfDirectory(at: appIconURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                            
                            if let firstMatchingFile = fileURLs.first(where: {
                                let isNotJSON = $0.pathExtension.lowercased() != "json"
                                let doesNotStartWithIcon = !$0.lastPathComponent.lowercased().hasPrefix("icon_")
                                return isNotJSON && doesNotStartWithIcon
                            }) {
                                return firstMatchingFile.path
                            }
                        } catch {
                            print("Error accessing files in \(appIconURL.path): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
        return nil
    }
}

enum FileType: String {
    case folder,
         proj,
         package,
         unknown
}
