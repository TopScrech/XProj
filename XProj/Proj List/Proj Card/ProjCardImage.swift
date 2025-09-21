import SwiftUI
import Kingfisher

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
                    .clipShape(.rect(cornerRadius: 10))
                
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
        .frame(45)
    }
}

#Preview {
    ProjCardImage(PreviewProp.previewProj1)
}
