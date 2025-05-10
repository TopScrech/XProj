import Foundation

func saveSecurityScopedBookmark(_ url: URL, forKey key: String, result: () -> ()) {
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
        print("Error saving bookmark for key \(key):", error)
    }
}
