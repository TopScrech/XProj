import SwiftUI

func restoreAccessToFolder(_ key: String) -> URL? {
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
            print("Bookmark data is stale. Need to reselect folder for a new bookmark")
            return nil
        }
        
        let accessStarted = url.startAccessingSecurityScopedResource()
        
        guard accessStarted else {
            print("Failed to start accessing security scoped resource for URL:", url)
            return nil
        }
        
        return url
    } catch {
        print("Error resolving bookmark data for key \(key):", error.localizedDescription)
        return nil
    }
}
