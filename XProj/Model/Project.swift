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
    
    struct PackageInfo {
        /// The name of the Swift package.
        let name: String
        /// The repository URL of the Swift package.
        let repositoryURL: String
        /// The kind of version requirement (e.g., branch, upToNextMajorVersion).
        let requirementKind: String
        /// The parameter associated with the requirement kind (e.g., branch name or minimum version).
        let requirementParam: String
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
                return "The specified `.xcodeproj` file was not found at the given path."
            case .failedToReadFile:
                return "Failed to read the contents of the `.xcodeproj` file."
            case .regexFailed:
                return "Failed to compile the regular expression for parsing."
            case .missingData(let detail):
                return "Missing data during parsing: \(detail)"
            case .invalidXcodeProjPath:
                return "The provided path does not point to a valid `.xcodeproj` file."
            }
        }
    }
    
    // MARK: - Function to Parse Swift Packages
    
    /// Parses Swift package references from an Xcode project.
    ///
    /// - Parameter path: The file system path to the `.xcodeproj` file.
    /// - Returns: An array of `PackageInfo` structs containing details about each Swift package.
    /// - Throws: `PackageParsingError` if any step of the parsing process fails.
    func parseSwiftPackages(_ path: String) throws -> [PackageInfo] {
        let fileManager = FileManager.default
        let folderURL = URL(fileURLWithPath: path)
        
        // Find the .xcodeproj file in the folder
        guard let xcodeProjURL = try? fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).first(where: { $0.pathExtension == "xcodeproj" }) else {
            throw PackageParsingError.projectFileNotFound
        }
        
        // Check if the .xcodeproj file exists
        guard fileManager.fileExists(atPath: xcodeProjURL.path) else {
            throw PackageParsingError.projectFileNotFound
        }

        let projectPbxprojPath = "\(xcodeProjURL.path.replacingOccurrences(of: "file://", with: ""))/project.pbxproj"
        
        // Read the contents of the .xcodeproj file
        let xcodeProjContent: String
        
        do {
            xcodeProjContent = try String(contentsOfFile: projectPbxprojPath, encoding: .utf8)
        } catch {
            print(projectPbxprojPath)
            throw PackageParsingError.failedToReadFile
        }
        
        // MARK: - Parsing Logic
        
        // Define the regular expression pattern to match XCRemoteSwiftPackageReference blocks
        let pattern = #"""
        /\* XCRemoteSwiftPackageReference\s+"(?<name>[^"]+)" \*/\s*=\s*\{
            \s*isa\s*=\s*XCRemoteSwiftPackageReference;
            \s*repositoryURL\s*=\s*"(?<repositoryURL>[^"]+)";
            \s*requirement\s*=\s*\{
                \s*(?:branch\s*=\s*(?<branch>[^;]+);\s*)?
                \s*(?:minimumVersion\s*=\s*(?<minimumVersion>[^;]+);\s*)?
                \s*kind\s*=\s*(?<kind>[^;]+);
            \s*\};
        \s*\};
        """#
//        let pattern = #"""
//        /\* XCRemoteSwiftPackageReference\s+"(?<name>[^"]+)" \*/\s*=\s*\{
//            \s*isa\s*=\s*XCRemoteSwiftPackageReference;
//            \s*repositoryURL\s*=\s*"(?<repositoryURL>[^"]+)";
//            \s*requirement\s*=\s*\{
//                \s*(?:(?:branch\s*=\s*(?<branch>[^;]+);)|(?:minimumVersion\s*=\s*(?<minimumVersion>[^;]+);))
//                \s*kind\s*=\s*(?<kind>[^;]+);
//            \s*\};
//        \s*\};
//        """#
        
        // Compile the regular expression with options to allow multiline matching
        let regexOptions: NSRegularExpression.Options = [.dotMatchesLineSeparators, .caseInsensitive]
        let regex: NSRegularExpression
        
        do {
            regex = try NSRegularExpression(pattern: pattern, options: regexOptions)
        } catch {
            throw PackageParsingError.regexFailed
        }
        
        // Define the range for the entire content
        let nsrange = NSRange(xcodeProjContent.startIndex..<xcodeProjContent.endIndex, in: xcodeProjContent)
        
        // Find all matches in the xcodeproj content
        let matches = regex.matches(in: xcodeProjContent, options: [], range: nsrange)
        
        if matches.isEmpty {
            print("No matches found")
        }
        
        var packages: [PackageInfo] = []
        
        // Iterate over each match to extract package information
        for match in matches {
            // Extract the package name
            guard let nameRange = Range(match.range(withName: "name"), in: xcodeProjContent) else {
                throw PackageParsingError.missingData("Package name not found in a match.")
            }
            
            let name = String(xcodeProjContent[nameRange])
            
            // Extract the repository URL
            guard let repositoryURLRange = Range(match.range(withName: "repositoryURL"), in: xcodeProjContent) else {
                throw PackageParsingError.missingData("Repository URL not found for package '\(name)'.")
            }
            let repositoryURL = String(xcodeProjContent[repositoryURLRange])
            
            // Extract the requirement kind
            guard let kindRange = Range(match.range(withName: "kind"), in: xcodeProjContent) else {
                throw PackageParsingError.missingData("Requirement kind not found for package '\(name)'.")
            }
            
            let kind = String(xcodeProjContent[kindRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Determine and extract the requirement parameter (branch or minimumVersion)
            var param = ""
            
            if let branchRange = Range(match.range(withName: "branch"), in: xcodeProjContent) {
                param = String(xcodeProjContent[branchRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            } else if let minimumVersionRange = Range(match.range(withName: "minimumVersion"), in: xcodeProjContent) {
                param = String(xcodeProjContent[minimumVersionRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                throw PackageParsingError.missingData("Neither branch nor minimumVersion found for package '\(name)'.")
            }
            
            // Create a PackageInfo instance and append it to the packages array
            let package = PackageInfo(
                name: name,
                repositoryURL: repositoryURL,
                requirementKind: kind,
                requirementParam: param
            )
            
            packages.append(package)
        }
        
        return packages
    }
}

enum FileType: String {
    case folder,
         proj,
         package,
         unknown
}
