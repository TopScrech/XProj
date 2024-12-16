import SwiftUI

struct PackageDepDetails: View {
    private let package: PackageDependency
    
    init(_ package: PackageDependency) {
        self.package = package
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text(package.name)
                    
                    if let author = package.package.author {
                        Text(author)
                            .secondary()
                    }
                }
            }
            .title()
            
            if let url = URL(string: package.package.repositoryURL) {
                Link(package.package.repositoryURL, destination: url)
            }
            
            Section("Projects using \(package.name)") {
                ForEach(package.projects) { proj in
//                    Text(proj.name)
                    ProjCard(proj)
                }
            }
        }
    }
}

//#Preview {
//    PackageDepDetails()
//}
