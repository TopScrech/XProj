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
                    
                    if let author = extractAuthor(package.repositoryURL) {
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
    
    private func extractAuthor(_ urlString: String) -> String? {
        // Attempt to create a URL object from the input string
        guard let url = URL(string: urlString) else {
            print("Invalid URL string")
            return nil
        }
        
        // Ensure the host is "github.com"
        guard url.host?.lowercased().contains("github.com") == true else {
            print("URL is not a GitHub repository")
            return nil
        }
        
        // Split the path into components
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        // GitHub repository URLs typically have the format: /author/repo
        guard pathComponents.count >= 2 else {
            print("URL does not contain enough path components")
            return nil
        }
        
        // The first component is the author
        let author = pathComponents[0]
        
        return author
    }
}

//#Preview {
//    ProjDetails()
//}
