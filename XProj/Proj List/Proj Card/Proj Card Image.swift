import SwiftUI

struct ProjCardImage: View {
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
                    .clipShape(.rect(cornerRadius: 5))
                
            } else if let icon = findIconComposerFile(at: proj.path) {
                Image(nsImage: icon)
                    .resizable()
                    .clipShape(.rect(cornerRadius: 5))
                
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
        .frame(width: 45, height: 45)
    }
    
    private func findIconComposerFile(at projectPath: String) -> NSImage? {
        let fm = FileManager.default
        let projectURL = URL(fileURLWithPath: projectPath)
        
        guard fm.fileExists(atPath: projectPath) else {
            print("File doesn't exist at path:", projectPath)
            return nil
        }
        
        // Check for AppIcon.icon
        let appIconURL = projectURL.appendingPathComponent("AppIcon.icon")
        if fm.fileExists(atPath: appIconURL.path) {
            return NSWorkspace.shared.icon(forFile: appIconURL.path)
        }
        
        // Otherwise, find the first .icon file
        guard let enumerator = fm.enumerator(at: projectURL, includingPropertiesForKeys: nil) else {
            return nil
        }
        
        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension.lowercased() == "icon" {
                return NSWorkspace.shared.icon(forFile: fileURL.path)
            }
        }
        
        return nil
    }
}

#Preview {
    ProjCardImage(previewProj1)
}
