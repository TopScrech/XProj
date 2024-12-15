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
        
        // MARK: - Parsing Logic (Line-by-Line)
        
        var packages: [PackageInfo] = []
        var currentPackage: PackageInfo?
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
                    currentPackage = PackageInfo(name: name, repositoryURL: "", requirementKind: "", requirementParam: "")
                }
                continue
            }
            
            // If we're inside a package block, extract properties
            if let package = currentPackage {
                if trimmedLine.starts(with: "repositoryURL =") {
                    // Extract repository URL
                    let repoPattern = #"repositoryURL\s*=\s*"([^"]+)";"#
                    if let repoURL = matchFirst(regex: repoPattern, in: trimmedLine, group: 1) {
                        currentPackage = PackageInfo(name: package.name, repositoryURL: repoURL, requirementKind: package.requirementKind, requirementParam: package.requirementParam)
                    }
                } else if trimmedLine.starts(with: "requirement = {") {
                    // Start of requirement block
                    currentProperty = "requirement"
                } else if currentProperty == "requirement" {
                    if trimmedLine.starts(with: "branch =") {
                        // Extract branch
                        let branchPattern = #"branch\s*=\s*([^;]+);"#
                        if let branch = matchFirst(regex: branchPattern, in: trimmedLine, group: 1) {
                            currentPackage = PackageInfo(name: package.name, repositoryURL: package.repositoryURL, requirementKind: "branch", requirementParam: branch)
                        }
                    } else if trimmedLine.starts(with: "minimumVersion =") {
                        // Extract minimum version
                        let minVersionPattern = #"minimumVersion\s*=\s*([^;]+);"#
                        if let minVersion = matchFirst(regex: minVersionPattern, in: trimmedLine, group: 1) {
                            currentPackage = PackageInfo(name: package.name, repositoryURL: package.repositoryURL, requirementKind: "upToNextMajorVersion", requirementParam: minVersion)
                        }
                    } else if trimmedLine.starts(with: "kind =") {
                        // Extract kind (in some cases, kind might come before branch/minimumVersion)
                        let kindPattern = #"kind\s*=\s*([^;]+);"#
                        if let kind = matchFirst(regex: kindPattern, in: trimmedLine, group: 1) {
                            if kind == "branch" {
                                currentPackage = PackageInfo(name: package.name, repositoryURL: package.repositoryURL, requirementKind: kind, requirementParam: "main")
                            } else {
                                currentPackage = PackageInfo(name: package.name, repositoryURL: package.repositoryURL, requirementKind: kind, requirementParam: "")
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
        
        // Validate that packages were found
        if packages.isEmpty {
            print("No packages found in the project.pbxproj file")
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
