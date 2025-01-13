import Foundation

final class ProjListVM {
    var projects: [Proj] = []
    
    private let fm = FileManager.default
    private let udKey = "projects_folder_bookmark"
    
    func getFolders(_ projectsFolder: String) -> [Proj] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            try processPath(projectsFolder)
        } catch {
            print("Error processing path: \(error.localizedDescription)")
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for processing projects: \(String(format: "%.3f", timeElapsed)) seconds")
        
        return projects
    }
    
    private func processPath(_ path: String) throws {
        let projects = try fm.contentsOfDirectory(atPath: path)
        
        for proj in projects {
            try processProj(proj, at: path)
        }
    }
    
    private func processProj(_ proj: String, at path: String) throws {
        var name = proj
        
        let projPath = path + "/" + name
        let attributes = try fm.attributesOfItem(atPath: projPath)
        
        let typeAttribute = attributes[.type] as? String ?? "Other"
        
        if let isHidden = attributes[.extensionHidden] as? Bool, isHidden {
            return
        }
        
        if name == ".git" || name == ".build" {
            return
        }
        
        let fileType: NavCategory
        
#warning("Workspaces are not fully supported")
        if hasFile(ofType: "xcodeproj", at: projPath) {
            if hasFile(ofType: "xcworkspace", at: projPath) {
                fileType = .workspace
            } else {
                fileType = .proj
            }
            
        } else if hasSwiftPackage(projPath) {
            fileType = hasVapor(projPath) ? .vapor : .package
            
        } else if name.contains(".playground") {
            fileType = .playground
            name = name.replacingOccurrences(of: ".playground", with: "")
            
        } else {
            switch typeAttribute {
            case "NSFileTypeDirectory":
                try processPath(projPath)
                return
                
            default:
                return
            }
        }
        
        guard let openedAt = lastAccessDate(projPath) else {
            return
        }
        
        let modifiedAt = attributes[.modificationDate] as? Date
        let createdAt = attributes[.creationDate] as? Date
        
        projects.append(
            Proj(
                id: projPath,
                name: name,
                path: projPath,
                type: fileType,
                openedAt: openedAt,
                modifiedAt: modifiedAt,
                createdAt: createdAt
                //                attributes: attributes
            )
        )
    }
    
    private func hasFile(ofType type: String, at path: String) -> Bool {
        do {
            let contents = try fm.contentsOfDirectory(atPath: path)
            
            return contents.contains {
                $0.hasSuffix("." + type)
            }
        } catch {
            return false
        }
    }
    
    private func hasSwiftPackage(_ path: String) -> Bool {
        do {
            let contents = try fm.contentsOfDirectory(atPath: path)
            
            return contents.contains("Package.swift")
        } catch {
            return false
        }
    }
    
    private func hasVapor( _ path: String) -> Bool {
        let resolvedPath = path + "/Package.resolved"
        
        guard fm.fileExists(atPath: resolvedPath) else {
            return false
        }
        
        let vaporUrl = "https://github.com/vapor/vapor.git"
        
        do {
            let fileContents = try String(contentsOfFile: resolvedPath, encoding: .utf8)
            
            let containsVapor = fileContents.contains(vaporUrl)
            
            return containsVapor
        } catch {
            return false
        }
    }
    
    private func lastAccessDate(_ path: String) -> Date? {
        path.withCString {
            var statStruct = Darwin.stat()
            
            guard stat($0, &statStruct) == 0 else {
                return nil
            }
            
            let interval = TimeInterval(statStruct.st_atimespec.tv_sec)
            
            return Date(timeIntervalSince1970: interval)
        }
    }
}
