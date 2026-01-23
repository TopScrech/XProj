import SwiftUI
import OSLog

struct BookmarkManager {
    static func saveSecurityScopedBookmark(_ url: URL, forKey key: String, result: () -> ()) {
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            UserDefaults.standard.set(bookmarkData, forKey: key)
            print("Bookmark saved successfully for key:", key)
            
            result()
        } catch {
            print("Error saving bookmark for key", key, error)
        }
    }
    
    static func openFolderPicker(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                completion(url)
            } else {
                completion(nil)
            }
        }
    }
    
    static func deleteBookmark(_ key: String) {
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: key) != nil {
            defaults.removeObject(forKey: key)
            print("Bookmark data deleted for key:", key)
        } else {
            print("No bookmark data found for key:", key)
        }
    }
    
    static func restoreAccessToFolder(_ key: String) -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: key) else {
            print("No bookmark data found for key:", key)
            return nil
        }
        
        var isStale = false
        
        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                bookmarkDataIsStale: &isStale
            )
            
            if isStale {
                Logger().warning("Bookmark data is stale. Reselect the folder")
                return nil
            }
            
            let accessStarted = url.startAccessingSecurityScopedResource()
            
            guard accessStarted else {
                print("Failed to start accessing security scoped resource for URL:", url)
                return nil
            }
            
            return url
        } catch {
            print("Error resolving bookmark data for key", key, error.localizedDescription)
            return nil
        }
    }
}
