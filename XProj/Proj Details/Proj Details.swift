import SwiftUI

struct ProjDetails: View {
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(proj.name)
            
            if let version = proj.swiftToolsVersion {
                Text("Swift tools: \(version)")
            }
            
            if let path = proj.projIcon(),
               let nsImage = NSImage(contentsOf: URL(fileURLWithPath: path)) {
                Image(nsImage: nsImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 16))
            }
            
            ForEach(proj.packages) { package in
                VStack(alignment: .leading) {
                    Text(package.name)
                    
                    Text(package.repositoryURL)
                    
                    Text("\(package.requirementKind): \(package.requirementParam)")
                        .footnote()
                        .secondary()
                }
                .padding(.vertical, 2)
            }
        }
    }
}

//#Preview {
//    ProjDetails()
//}
