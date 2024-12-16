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
    var targets: [(target: PBXNativeTarget, bundleID: String?)] = []
    
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
        case .folder:  "folder"
        case .proj:    "hammer.fill"
        case .package: "shippingbox.fill"
        case .playground: "swift"
        case .unknown: "questionmark"
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
    
    // MARK: - Enum for Parsing Errors
    
    /// An enumeration of possible errors that can occur during the parsing of Swift packages from an Xcode project.
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
    
    // MARK: - Function to Parse Swift Packages
    
    /// Parses Swift package references from an Xcode project.
    ///
    /// - Parameter path: The file system path to the `.xcodeproj` file.
    /// - Returns: An array of `PackageInfo` structs containing details about each Swift package.
    /// - Throws: `PackageParsingError` if any step of the parsing process fails.
    func parseSwiftPackages() -> [Package] {
        guard type == .proj else {
            return []
        }
        
        let fileManager = FileManager.default
        let folderURL = URL(fileURLWithPath: path)
        
        // Find the .xcodeproj file in the folder
        guard let xcodeProjURL = try? fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).first(where: { $0.pathExtension == "xcodeproj" }) else {
            print("projectFileNotFound")
            return []
        }
        
        // Check if the .xcodeproj file exists
        guard fileManager.fileExists(atPath: xcodeProjURL.path) else {
            print("projectFileNotFound")
            return []
        }
        
        let projectPbxprojPath = "\(xcodeProjURL.path.replacingOccurrences(of: "file://", with: ""))/project.pbxproj"
        
        // Read the contents of the .xcodeproj file
        let xcodeProjContent: String
        
        do {
            xcodeProjContent = try String(contentsOfFile: projectPbxprojPath, encoding: .utf8)
        } catch {
            print(projectPbxprojPath)
            print("failedToReadFile")
            return []
        }
        
        // MARK: - Parsing Logic (Line-by-Line)
        
        var packages: [Package] = []
        var currentPackage: Package?
        var currentProperty: String?
        
        // Split the content into lines for easier processing
        let lines = xcodeProjContent.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for the start of a package reference
            if trimmedLine.contains("/* XCRemoteSwiftPackageReference") && trimmedLine.contains("*/ = {") {
                // Extract the package name using regex
                let namePattern = #"/\* XCRemoteSwiftPackageReference\s+"([^"]+)" \*/ = \{"#
                
                if let name = matchFirst(regex: namePattern, in: trimmedLine, group: 1) {
                    currentPackage = Package(name: name, repositoryURL: "", requirementKind: "", requirementParam: "")
                }
                
                continue
            }
            
            // If we're inside a package block, extract properties
            if let package = currentPackage {
                if trimmedLine.starts(with: "repositoryURL =") {
                    // Extract repository URL
                    let repoPattern = #"repositoryURL\s*=\s*"([^"]+)";"#
                    
                    if let repoURL = matchFirst(regex: repoPattern, in: trimmedLine, group: 1) {
                        currentPackage = Package(name: package.name, repositoryURL: repoURL, requirementKind: package.requirementKind, requirementParam: package.requirementParam)
                    }
                } else if trimmedLine.starts(with: "requirement = {") {
                    // Start of requirement block
                    currentProperty = "requirement"
                } else if currentProperty == "requirement" {
                    if trimmedLine.starts(with: "branch =") {
                        // Extract branch
                        let branchPattern = #"branch\s*=\s*([^;]+);"#
                        
                        if let branch = matchFirst(regex: branchPattern, in: trimmedLine, group: 1) {
                            currentPackage = Package(name: package.name, repositoryURL: package.repositoryURL, requirementKind: "branch", requirementParam: branch)
                        }
                    } else if trimmedLine.starts(with: "minimumVersion =") {
                        // Extract minimum version
                        let minVersionPattern = #"minimumVersion\s*=\s*([^;]+);"#
                        
                        if let minVersion = matchFirst(regex: minVersionPattern, in: trimmedLine, group: 1) {
                            currentPackage = Package(name: package.name, repositoryURL: package.repositoryURL, requirementKind: "upToNextMajorVersion", requirementParam: minVersion)
                        }
                    } else if trimmedLine.starts(with: "kind =") {
                        // Extract kind (in some cases, kind might come before branch/minimumVersion)
                        let kindPattern = #"kind\s*=\s*([^;]+);"#
                        
                        if let kind = matchFirst(regex: kindPattern, in: trimmedLine, group: 1) {
                            if kind == "branch" {
                                currentPackage = Package(name: package.name, repositoryURL: package.repositoryURL, requirementKind: kind, requirementParam: "main")
                            } else {
                                currentPackage = Package(name: package.name, repositoryURL: package.repositoryURL, requirementKind: kind, requirementParam: "")
                            }
                        }
                    } else if trimmedLine == "};" {
                        // End of requirement block
                        currentProperty = nil
                    }
                }
                
                // Check for end of package block
                if trimmedLine == "};" {
                    if let completedPackage = currentPackage {
                        packages.append(completedPackage)
                        currentPackage = nil
                    }
                }
            }
        }
        
        return packages
    }
}

func matchFirst(regex: String, in text: String, group: Int) -> String? {
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsrange = NSRange(text.startIndex..<text.endIndex, in: text)
        
        if
            let match = regex.firstMatch(in: text, options: [], range: nsrange),
            match.numberOfRanges > group,
            let range = Range(match.range(at: group), in: text)
        {
            return String(text[range])
        }
    } catch {
        print("Invalid regex: \(regex)")
    }
    
    return nil
}
