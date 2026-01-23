import Foundation

func sanitizedXcodeProjURL(_ url: URL) -> URL? {
    let pbxprojURL = url.appendingPathComponent("project.pbxproj")
    
    guard let contents = try? String(contentsOf: pbxprojURL) else {
        return url
    }
    
    guard contents.contains("PBXFileSystemSynchronized") else {
        return url
    }
    
    let sanitized = sanitizeXcodeProjContents(contents)
    let fm = FileManager.default
    let tempURL = fm.temporaryDirectory
        .appendingPathComponent("xproj-sanitized-\(UUID().uuidString).xcodeproj", isDirectory: true)
    
    do {
        try fm.createDirectory(at: tempURL, withIntermediateDirectories: true)
        try sanitized.write(
            to: tempURL.appendingPathComponent("project.pbxproj"),
            atomically: true,
            encoding: .utf8
        )
        return tempURL
    } catch {
        return nil
    }
}

private func sanitizeXcodeProjContents(_ contents: String) -> String {
    let lines = contents.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    var output: [String] = []
    output.reserveCapacity(lines.count)
    
    var skipExceptionSection = false
    var skipExceptionsBlock = false
    var inRootGroup = false
    var rootGroupHasChildren = false
    
    for line in lines {
        if line.contains("/* Begin PBXFileSystemSynchronizedBuildFileExceptionSet section */") {
            skipExceptionSection = true
            continue
        }
        
        if skipExceptionSection {
            if line.contains("/* End PBXFileSystemSynchronizedBuildFileExceptionSet section */") {
                skipExceptionSection = false
            }
            continue
        }
        
        if line.contains("isa = PBXFileSystemSynchronizedRootGroup;") {
            inRootGroup = true
            rootGroupHasChildren = false
            output.append(
                line.replacingOccurrences(
                    of: "PBXFileSystemSynchronizedRootGroup",
                    with: "PBXGroup"
                )
            )
            continue
        }
        
        if inRootGroup {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmed.hasPrefix("children = (") {
                rootGroupHasChildren = true
            }
            
            if trimmed.hasPrefix("exceptions = (") {
                skipExceptionsBlock = true
                continue
            }
            
            if skipExceptionsBlock {
                if trimmed == ");" {
                    skipExceptionsBlock = false
                }
                continue
            }
            
            if trimmed == "};" {
                if !rootGroupHasChildren {
                    output.append("\t\t\tchildren = (")
                    output.append("\t\t\t);")
                }
                output.append(line)
                inRootGroup = false
                continue
            }
        }
        
        output.append(line)
    }
    
    return output.joined(separator: "\n")
}
