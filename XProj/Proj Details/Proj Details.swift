import ScrechKit

struct ProjDetails: View {
    @Environment(ProjListVM.self) private var vm
    
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        List {
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
            
            Button {
                vm.openProjects([proj.path])
            } label: {
                Text("Open in Xcode")
            }
            
            Button {
                openInFinder(rootedAt: proj.path)
            } label: {
                Text("Open in Finder")
            }
            
            ForEach(proj.packages) { package in
                VStack(alignment: .leading) {
                    Text(package.name)
                    
                    if let author = package.author {
                        Text(author)
                            .footnote()
                            .secondary()
                    }
                    
                    Text("\(package.requirementKind): \(package.requirementParam)")
                        .footnote()
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 2)
            }
        }
    }
}

//#Preview {
//    ProjDetails()
//}
