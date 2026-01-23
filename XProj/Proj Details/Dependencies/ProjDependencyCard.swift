import SwiftUI

struct ProjDependencyCard: View {
    private let pkg: Package
    
    init(_ pkg: Package) {
        self.pkg = pkg
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(pkg.name)
                
                if let author = pkg.author {
                    Text(author)
                        .footnote()
                        .secondary()
                }
                
                if let requirement = pkg.requirementKind, let param = pkg.requirementParam {
                    Text("\(requirement): \(param)")
                        .footnote()
                        .tertiary()
                }
            }
            
            Spacer()
            
            if let url = URL(string: pkg.repositoryURL) {
                Link(destination: url) {
                    Image(systemName: "link")
                }
                .help(url)
            }
        }
        .padding(.vertical, 2)
        .contextMenu {
            if let url = URL(string: pkg.repositoryURL) {
                Link(destination: url) {
                    Label("Remove", systemImage: "app.connected.to.app.below.fill")
                }
                .help(url)
                
                ShareLink(item: url)
                    .help(url)
            }
        }
    }
}

#Preview {
    ProjDependencyCard(
        Package(name: "Preview", repositoryURL: "")
    )
    .darkSchemePreferred()
}
