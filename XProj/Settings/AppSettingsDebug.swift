import SwiftUI
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
            print("Examples.zip not found")
            return
        }
        
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            print("Downloads folder not located")
            return
        }
        
        let destinationURL = downloadsURL.appendingPathComponent("Examples.zip")
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            print("Examples.zip successfully copied to the Downloads folder")
        } catch {
            print("Error copying Examples.zip:", error.localizedDescription)
        }
    }
}

#Preview {
    AppSettingsDebug()
        .darkSchemePreferred()
        .environment(NavModel())
}
