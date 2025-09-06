import SwiftUI

struct DependencyDetails: View {
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
            
            if let url = URL(string: dependency.package.repositoryUrl) {
                Link(dependency.package.repositoryUrl, destination: url)
            }
            
            Section("Projects using \(dependency.name)") {
                ForEach(dependency.sortedProjects) {
                    ProjCard($0)
                }
            }
        }
    }
}

//#Preview {
//    DependencyDetails()
//}
