import SwiftUI

struct ProjDependency: View {
    private let package: Package
    
    init(_ package: Package) {
        self.package = package
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(package.name)
                
                if let author = package.author {
                    Text(author)
                        .footnote()
                        .secondary()
                }
                
                if let requirement = package.requirementKind, let param = package.requirementParam {
                    Text("\(requirement): \(param)")
                        .footnote()
                        .tertiary()
                }
            }
            
            Spacer()
            
            if let url = URL(string: package.repositoryUrl) {
                Link(destination: url) {
                    Image(systemName: "link")
                }
                .help(url)
            }
        }
        .padding(.vertical, 2)
        .contextMenu {
            if let url = URL(string: package.repositoryUrl) {
                Link("Remote", destination: url)
                    .help(url)
            }
        }
    }
}

#Preview {
    ProjDependency(
        Package(name: "Preview", repositoryUrl: "")
    )
}
