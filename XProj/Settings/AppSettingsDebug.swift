import SwiftUI
import Kingfisher

struct AppSettingsDebug: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        Section("Debug") {
            Button("Save example projects to Downloads", systemImage: "square.and.arrow.down") {
                downloadExamples()
            }
            
            Button("Clear all saved projects", systemImage: "xmark") {
                clearAllCache()
            }
            
            Button("Clear navigation path", systemImage: "xmark") {
                nav.clearNavCache()
            }
            
            .foregroundStyle(.red)
        }
    }
    
    private func clearAllCache() {
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
    }
    
    private func downloadExamples() {
        guard
            let sourceUrl = Bundle.main.url(forResource: "Examples", withExtension: "zip")
        else {
            print("Examples.zip not found")
            return
        }
        
        guard
            let downloadsUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        else {
            print("Downloads folder not located")
            return
        }
        
        let destinationUrl = downloadsUrl.appendingPathComponent("Examples.zip")
        
        do {
            try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
            print("Examples.zip successfully copied to the Downloads folder")
        } catch {
            print("Error copying Examples.zip:", error.localizedDescription)
        }
    }
}

#Preview {
    AppSettingsDebug()
        .environment(NavModel())
}
