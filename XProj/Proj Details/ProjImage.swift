import SwiftUI
import Kingfisher

struct ProjImage: View {
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    var body: some View {
        Group {
            if let path = proj.projIcon(),
               let nsImage = NSImage(contentsOf: URL(fileURLWithPath: path)) {
                Image(nsImage: nsImage)
                    .resizable()
                    .clipShape(.rect(cornerRadius: 10))
                    .onDrag {
                        let fileURL = URL(fileURLWithPath: path)
                        return NSItemProvider(object: fileURL as NSURL)
                    }
                    .contextMenu {
                        Button("Open in Finder", systemImage: "finder") {
                            openInFinder(path)
                        }
                        
                        Button("Copy", systemImage: "document.on.document") {
                            copyToPasteboard(path)
                        }
                        
                        Button("Save to Downloads", systemImage: "square.and.arrow.down") {
                            saveToDownloads(path)
                        }
                        
                        ShareLink(item: URL(fileURLWithPath: path))
                    }
                
            } else if let appStoreTarget = proj.targets.first(where: { $0.appStoreApp != nil }) {
                KFImage(appStoreTarget.appStoreApp?.artworkUrl512)
                    .resizable()
                    .clipShape(.rect(cornerRadius: 10))
                
            } else if proj.type == .proj {
                Image(.projIcon)
                    .resizable()
                
            } else if proj.type == .workspace {
                Image(.xcodeWorkspace)
                    .resizable()
                
            } else if proj.type == .vapor {
                Image(.vapor)
                    .resizable()
                
            } else {
                Image(systemName: proj.icon)
                    .fontSize(32)
                    .foregroundStyle(proj.iconColor.gradient)
            }
        }
        .frame(100)
    }
    
    private func openInFinder(_ path: String) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
    }
    
    private func copyToPasteboard(_ path: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([NSURL(fileURLWithPath: path)])
    }
    
    private func saveToDownloads(_ path: String) {
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        
        guard let downloadsURL else {
            return
        }
        
        let fileName = URL(fileURLWithPath: path).lastPathComponent
        let destinationURL = downloadsURL.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: destinationURL)
        } catch {
            print("Error saving file to Downloads:", error.localizedDescription)
        }
    }
}

#Preview {
    ProjCardImage(PreviewProp.previewProj1)
        .darkSchemePreferred()
}
