import SwiftUI

struct ProjectCardImage: View {
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        if let path = proj.projectIcon(),
           let nsImage = NSImage(contentsOf: URL(fileURLWithPath: path)) {
            Image(nsImage: nsImage)
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(.rect(cornerRadius: 5))
        } else if proj.type == .proj {
            Image(.projIcon)
                .resizable()
                .frame(width: 32, height: 32)
                .scaledToFit()
        } else {
            Image(systemName: proj.icon)
                .title()
                .foregroundStyle(proj.iconColor.gradient)
                .frame(width: 32)
        }
    }
}

//#Preview {
//    ProjectCardImage()
//}
