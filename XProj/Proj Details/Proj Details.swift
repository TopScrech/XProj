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
                .title()
            
            if let path = proj.projIcon(),
               let nsImage = NSImage(contentsOf: URL(fileURLWithPath: path)) {
                Image(nsImage: nsImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 16))
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Last opened: ")
                    .foregroundStyle(.secondary) +
                
                Text("\(proj.openedAt)")
                
                if let modifiedAt = proj.modifiedAt {
                    Text("Modified: ")
                        .foregroundStyle(.secondary) +
                    
                    Text("\(modifiedAt)")
                }
                
                if let createdAt = proj.createdAt {
                    Text("Created: ")
                        .foregroundStyle(.secondary) +
                    
                    Text("\(createdAt)")
                }
            }
            .footnote()
            
            if let version = proj.swiftToolsVersion {
                Text("Swift tools: \(version)")
            }
            
            HStack {
                Button("Xcode") {
                    vm.openProjects([proj.path])
                }
                
                Button("Finder") {
                    openInFinder(rootedAt: proj.path)
                }
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
