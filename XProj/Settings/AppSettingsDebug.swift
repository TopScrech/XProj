import SwiftUI
import OSLog
import Kingfisher

struct AppSettingsDebug: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        Section("Debug") {
            Button("Save example projects to Downloads", systemImage: "square.and.arrow.down", action: downloadExamples)
            Button("Clear cached projects", systemImage: "xmark", action: clearAllCache)
            Button("Clear navigation path", systemImage: "xmark", action: nav.clearNavCache)
                .foregroundStyle(.red)
        }
    }
    
    private func clearAllCache() {
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
    }
    
    private func downloadExamples() {
        guard let sourceURL = Bundle.main.url(forResource: "Examples", withExtension: "zip") else {
            Logger().error("Examples.zip not found")
            return
        }
        
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            Logger().error("Downloads folder not located")
            return
        }
        
        let destinationURL = downloadsURL.appendingPathComponent("Examples.zip")
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            Logger().info("Examples.zip copied to the Downloads folder")
        } catch {
            Logger().error("Can't copying Examples.zip: \(error)")
        }
    }
}

#Preview {
    AppSettingsDebug()
        .darkSchemePreferred()
        .environment(NavModel())
}
