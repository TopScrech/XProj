import SwiftUI

struct ProjDetailsPackage: View {
    private let package: Package
    
    init(_ package: Package) {
        self.package = package
    }
    
    var body: some View {
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
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
        .contextMenu {
            if let url = URL(string: package.repositoryURL) {
                Link("Open in browser", destination: url)
            }
        }
    }
}

//#Preview {
//    ProjDetailsPackage()
//}
