import SwiftUI

func restoreAccessToFolder(_ key: String) -> URL? {
    guard let bookmarkData = UserDefaults.standard.data(forKey: key) else {
        print("No bookmark data found")
        return nil
    }
    
    var isStale = false
    
    do {
        let url = try URL(
            resolvingBookmarkData: bookmarkData,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        
        if isStale {
            print("Bookmark data is stale. Need to reselect folder for a new bookmark")
            return nil
        }
        
        let accessStarted = url.startAccessingSecurityScopedResource()
        
        if !accessStarted {
            print("Failed to start accessing security scoped resource")
            return nil
        }
        
        return url
    } catch {
        print("Error resolving bookmark data: \(error.localizedDescription)")
        return nil
    }
}
