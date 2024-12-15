import SwiftUI

struct ProjectDetails: View {
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        VStack {
            Text(proj.name)
            
            if let path = proj.projectIcon(),
               let nsImage = NSImage(contentsOf: URL(fileURLWithPath: path)) {
                Image(nsImage: nsImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 16))
            }
        }
    }
}

//#Preview {
//    ProjectDetails()
//}
