import Foundation

func sanitizedXcodeProjURL(_ url: URL) -> URL? {
    let pbxprojURL = url.appendingPathComponent("project.pbxproj")
    
    guard let contents = try? String(contentsOf: pbxprojURL) else {
        return url
    }
    
    guard contents.contains("PBXFileSystemSynchronized") || contents.contains("XCLocalSwiftPackageReference") else {
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
    
    let localPackageIds = collectLocalPackageIds(lines)
    let productDependencyIds = collectLocalProductDependencyIds(lines, localPackageIds)
    
    var inLocalPackageSection = false
    var currentObjectId: String?
    var skipCurrentObject = false
    
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
        
        if line.contains("/* Begin XCLocalSwiftPackageReference section */") {
            inLocalPackageSection = true
            continue
        }
        
        if inLocalPackageSection {
            if line.contains("/* End XCLocalSwiftPackageReference section */") {
                inLocalPackageSection = false
            }
            continue
        }
        
        if let objectId = objectIdFromLine(line) {
            currentObjectId = objectId
            skipCurrentObject = productDependencyIds.contains(objectId)
        }
        
        if skipCurrentObject {
            if line.trimmingCharacters(in: .whitespacesAndNewlines) == "};" {
                currentObjectId = nil
                skipCurrentObject = false
            }
            continue
        }
        
        if containsAnyId(line, localPackageIds) || containsAnyId(line, productDependencyIds) {
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

private func collectLocalPackageIds(_ lines: [String]) -> Set<String> {
    var localPackageIds: Set<String> = []
    var inLocalPackageSection = false
    
    for line in lines {
        if line.contains("/* Begin XCLocalSwiftPackageReference section */") {
            inLocalPackageSection = true
            continue
        }
        
        if inLocalPackageSection {
            if line.contains("/* End XCLocalSwiftPackageReference section */") {
                inLocalPackageSection = false
                continue
            }
            
            if let objectId = objectIdFromLine(line) {
                localPackageIds.insert(objectId)
            }
        }
    }
    
    return localPackageIds
}

private func collectLocalProductDependencyIds(_ lines: [String], _ localPackageIds: Set<String>) -> Set<String> {
    guard !localPackageIds.isEmpty else {
        return []
    }
    
    var productDependencyIds: Set<String> = []
    var currentObjectId: String?
    var currentObjectIsProductDependency = false
    var currentObjectHasLocalPackage = false
    
    for line in lines {
        if let objectId = objectIdFromLine(line) {
            currentObjectId = objectId
            currentObjectIsProductDependency = false
            currentObjectHasLocalPackage = false
        }
        
        if line.contains("isa = XCSwiftPackageProductDependency;") {
            currentObjectIsProductDependency = true
        }
        
        if currentObjectIsProductDependency, localPackageIdFromLine(line, localPackageIds) != nil {
            currentObjectHasLocalPackage = true
        }
        
        if line.trimmingCharacters(in: .whitespacesAndNewlines) == "};" {
            if currentObjectIsProductDependency, currentObjectHasLocalPackage, let currentObjectId {
                productDependencyIds.insert(currentObjectId)
            }
            currentObjectId = nil
            currentObjectIsProductDependency = false
            currentObjectHasLocalPackage = false
        }
    }
    
    return productDependencyIds
}

private func objectIdFromLine(_ line: String) -> String? {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    
    guard trimmed.count >= 25, trimmed.contains(" = {") else {
        return nil
    }
    
    let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
    
    guard let first = parts.first, first.count == 24 else {
        return nil
    }
    
    return String(first)
}

private func localPackageIdFromLine(_ line: String, _ localPackageIds: Set<String>) -> String? {
    guard line.contains("package =") else {
        return nil
    }
    
    for id in localPackageIds where line.contains(id) {
        return id
    }
    
    return nil
}

private func containsAnyId(_ line: String, _ ids: Set<String>) -> Bool {
    for id in ids where line.contains(id) {
        return true
    }
    
    return false
}
