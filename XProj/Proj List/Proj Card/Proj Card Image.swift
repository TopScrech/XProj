import SwiftUI

struct ProjCardImage: View {
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        Group {
            if let path = proj.projIcon(),
               let nsImage = NSImage(contentsOf: URL(fileURLWithPath: path)) {
                Image(nsImage: nsImage)
                    .resizable()
                    .clipShape(.rect(cornerRadius: 5))
                
            } else if proj.type == .proj {
                Image(.projIcon)
                    .resizable()
                
            } else if proj.type == .vapor {
                Image(.vapor)
                    .resizable()
                
            } else {
                Image(systemName: proj.icon)
                    .title()
                    .foregroundStyle(proj.iconColor.gradient)
            }
        }
        .frame(width: 32, height: 32)
    }
}

//#Preview {
//    ProjCardImage()
//}
