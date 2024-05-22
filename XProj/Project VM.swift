import SwiftUI

@Observable
final class ProjectVM {
    var projects: [Project] = []
    
    private let udKey = "projects_folder_bookmark"
    
    func getFolders() {
        restoreAccessToFolder()
        projects = []
        
        let fm = FileManager.default
        
        do {
            guard let bookmarkData = UserDefaults.standard.data(forKey: udKey) else {
                return
            }
            
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
            
            if isStale {
                print("Bookmark data is stale. Need to reselect folder for a new bookmark")
                return
            }
            
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to start accessing security scoped resource")
                return
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            let path = url.path
            
            print(#function + "\(path)")
            
            let projects = try fm.contentsOfDirectory(atPath: path)
            
            for project in projects {
                let attributes = try fm.attributesOfItem(atPath: "\(path)/\(project)")
                
                let typeAttribute = attributes[.type] as? String ?? "Other"
                
                //                if hasXcodeproj("\(path)/\(project)") {
                //                    type = .project
                //                } else {
                //                    type = .other
                //                }
                
                if let isHidden = attributes[.extensionHidden] as? Bool, isHidden {
                    continue
                }
                
                if project.hasSuffix(".xcodeproj") {
                    print("F")
                }
                
                self.projects.append(
                    .init(
                        name: project,
                        type: typeAttribute,
                        attributes: attributes
                    )
                )
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func hasXcodeproj(_ path: String) -> Bool {
        print(#function)
        
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            
            return contents.contains {
                $0.hasSuffix(".xcodeproj")
            }
        } catch {
            print("Failed to read directory contents: \(path)")
            return false
        }
    }
    
    func openFolderPicker() {
        print(#function)
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.saveBookmark(url)
            }
        }
    }
    
    private func saveBookmark(_ url: URL) {
        print(#function + " save \(url)")
        
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            UserDefaults.standard.set(bookmarkData, forKey: udKey)
            
            getFolders()
        } catch {
            print("Error saving bookmark: \(error)")
        }
    }
    
    func restoreAccessToFolder() {
        print(#function)
        
        guard let bookmarkData = UserDefaults.standard.data(forKey: udKey) else {
            return
        }
        
        var isStale = false
        
        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            if url.startAccessingSecurityScopedResource() {
                // You can now access the folder here
#warning("Remember to call `stopAccessingSecurityScopedResource()` when access is no longer needed")
            }
            
            if isStale {
                // Bookmark data is stale, need to save a new bookmark
                print("Bookmark data is stale. Need to reselect folder for a new bookmark.")
            }
        } catch {
            print("Error restoring access: \(error)")
        }
    }
}
