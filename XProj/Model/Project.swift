import SwiftUI
import XcodeProjKit

struct Project: Identifiable, Hashable {
    let id = UUID()
    let name, path: String
    let type: ProjType
    let openedAt: Date
    let modifiedAt: Date?
    let createdAt: Date?
    let attributes: [FileAttributeKey: Any]
    
    var swiftToolsVersion: String? = nil
    var packages: [Package] = []
    var targets: [Target] = []
    
    init(
        name: String,
        path: String,
        type: ProjType,
        openedAt: Date,
        modifiedAt: Date?,
        createdAt: Date?,
        attributes: [FileAttributeKey : Any]
    ) {
        self.name = name
        self.path = path
        self.type = type
        self.openedAt = openedAt
        self.modifiedAt = modifiedAt
        self.createdAt = createdAt
        self.attributes = attributes
        
        self.swiftToolsVersion = fetchSwiftToolsVersion()
        self.packages = parseSwiftPackages()
        self.targets = fetchTargets()
    }
    
    var icon: String {
        switch type {
        case .folder:     "folder"
        case .proj:       "hammer.fill"
        case .package:    "shippingbox.fill"
        case .playground: "swift"
        case .unknown:    "questionmark"
        }
    }
    
    var iconColor: Color {
        switch type {
        case .folder:     .yellow
        case .proj:       .blue
        case .package:    .package
        case .playground: .blue
        case .unknown:    .gray
        }
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(path)
        hasher.combine(type)
        hasher.combine(openedAt)
        
        // Convert attributes to a hashable form
        let attributeArray = attributes.map {
            ($0.key, $0.value)
        }
        
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
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.path == rhs.path &&
        lhs.type == rhs.type &&
        lhs.openedAt == rhs.openedAt &&
        lhs.attributesAreEqual(rhs.attributes)
    }
    
    private func attributesAreEqual(_ otherAttributes: [FileAttributeKey: Any]) -> Bool {
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
    
    enum PackageParsingError: Error, LocalizedError {
        /// Indicates that the `.xcodeproj` file was not found at the specified path.
        case projectFileNotFound
        
        /// Indicates a failure to read the contents of the `.xcodeproj` file.
        case failedToReadFile
        
        /// Indicates a failure to compile the regular expression used for parsing.
        case regexFailed
        
        /// Indicates that essential data was missing during parsing, with an associated detail message.
        case missingData(String)
        
        /// Indicates that the provided path does not point to a valid `.xcodeproj` file.
        case invalidXcodeProjPath
        
        var errorDescription: String? {
            switch self {
            case .projectFileNotFound:
                "The specified `.xcodeproj` file was not found at the given path."
                
            case .failedToReadFile:
                "Failed to read the contents of the `.xcodeproj` file."
                
            case .regexFailed:
                "Failed to compile the regular expression for parsing."
                
            case .missingData(let detail):
                "Missing data during parsing: \(detail)"
                
            case .invalidXcodeProjPath:
                "The provided path does not point to a valid `.xcodeproj` file."
            }
        }
    }
    
    func parseSwiftPackages() -> [Package] {
        switch type {
        case .proj:
            parsePackagesInProj()
            
        case .package:
            parsePackagesInPackage()
            
            //        case .playground:
            
        default:
            []
        }
    }
    
    func parsePackagesInProj() -> [Package] {
        guard let url = fetchProjectFilePath(path) else {
            return []
        }
        
        do {
            let xcodeProj = try XcodeProj(url: url)
            let project = xcodeProj.project
            let packages = project.packageReferences
            
            let result = packages.compactMap { package in
                if let rep = package.repositoryURL,
                   let name = URL(string: rep)?.lastPathComponent {
                    return Package(
                        name: name,
                        repositoryURL: rep,
                        requirementKind: package.requirement?.keys.first ?? "",
                        requirementParam: package.requirement?.values.first as? String ?? ""
                    )
                }
                
                return nil
            }
            
            return result
        } catch {
            print(error)
            return []
        }
    }
}
