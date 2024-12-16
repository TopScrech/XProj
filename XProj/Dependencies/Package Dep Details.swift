import SwiftUI

struct PackageDepDetails: View {
    private let dependency: PackageDependency
    
    init(_ dependency: PackageDependency) {
        self.dependency = dependency
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text(dependency.name)
                    
                    if let author = dependency.author {
                        Text(author)
                            .secondary()
                    }
                }
            }
            .title()
            
            if let url = URL(string: dependency.package.repositoryURL) {
                Link(dependency.package.repositoryURL, destination: url)
            }
            
            Section("Projects using \(dependency.name)") {
                ForEach(dependency.projects) { proj in
                    ProjCard(proj)
                }
            }
        }
    }
}

//#Preview {
//    PackageDepDetails()
//}
