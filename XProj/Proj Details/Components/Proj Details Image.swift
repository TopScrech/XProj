import SwiftUI

struct ProjDetailsImage: View {
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    var body: some View {
        if let path = proj.projIcon(),
           let nsImage = NSImage(contentsOf: URL(fileURLWithPath: path)) {
            Image(nsImage: nsImage)
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(.rect(cornerRadius: 16))
                .onDrag {
                    let fileURL = URL(fileURLWithPath: path)
                    return NSItemProvider(object: fileURL as NSURL)
                }
                .contextMenu {
                    Button("Save to Downloads") {
                        saveToDownloads(path)
                    }
                    
                    ShareLink(item: URL(fileURLWithPath: path))
                }
        }
    }
    
    private func saveToDownloads(_ path: String) {
        let downloadsUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        
        guard let downloadsUrl else {
            return
        }
        
        let fileName = URL(fileURLWithPath: path).lastPathComponent
        let destinationUrl = downloadsUrl.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: destinationUrl)
        } catch {
            print("Error saving file to Downloads:", error.localizedDescription)
        }
    }
}
