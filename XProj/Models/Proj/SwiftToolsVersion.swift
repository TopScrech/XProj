import Foundation
import OSLog

extension Proj {
    /// Fetches and returns the Swift tools version from `Package.swift` located in the given folder path.
    ///
    /// - Parameter folderPath: The path to the folder containing `Package.swift`.
    /// - Returns: A `String` representing the Swift tools version (e.g., "5.9") if found, otherwise `nil`
    func fetchSwiftToolsVersion() -> String? {
        guard type == .package || type == .vapor else {
            return nil
        }
        
        // Create a URL from the folder path
        let folderURL = URL(fileURLWithPath: path, isDirectory: true)
        
        // Construct the URL to `Package.swift` by appending the file name to the folder URL
        let packageSwiftURL = folderURL.appendingPathComponent("Package.swift")
        
        let fm = FileManager.default
        
        // Check if the folder exists and is a directory
        var isDirectory: ObjCBool = false
        let folderExists = fm.fileExists(atPath: folderURL.path, isDirectory: &isDirectory)
        
        if !folderExists || !isDirectory.boolValue {
            print("Error: The folder path '\(path)' does not exist or isn't a dir")
            return nil
        }
        
        // Check if `Package.swift` exists
        let fileExists = fm.fileExists(atPath: packageSwiftURL.path)
        
        if !fileExists {
            Logger().error("'Package.swift' doesn't exist in the folder: \(path)")
            return nil
        }
        
        do {
            // Read the contents of `Package.swift` as a string
            let contents = try String(contentsOf: packageSwiftURL, encoding: .utf8)
            
            // Split the contents into lines
            let lines = contents.components(separatedBy: .newlines)
            
            // Iterate through each line to find the swift-tools-version declaration
            for line in lines {
                // Trim whitespace and check if the line starts with "// swift-tools-version:"
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                
                if trimmedLine.hasPrefix("// swift-tools-version:") {
                    // Extract the version number by removing the prefix
                    let prefix = "// swift-tools-version:"
                    
                    let versionString = trimmedLine
                        .replacing(prefix, with: "")
                        .trimmingCharacters(in: .whitespaces)
                    
                    // Optionally, validate the version format (e.g., matches a regex for versions like 5.9)
                    // Here, we assume the format is correct
                    
                    return versionString
                }
            }
            
            // If the swift-tools-version line is not found
            print("Error: 'swift-tools-version' declaration not found in 'Package.swift'")
            return nil
        } catch {
            // Handle any errors that occur during file reading
            print("An error occurred while reading 'Package.swift':", error.localizedDescription)
            return nil
        }
    }
}
