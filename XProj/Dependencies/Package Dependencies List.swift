import SwiftUI

struct PackageDependency: Identifiable {
    let id = UUID()
    
    let package: Package
    let proj: [Project]
    
    var name: String {
        package.name
    }
    
    var useCount: Int {
        proj.count
    }
}

struct PackageDependenciesList: View {
    @Environment(ProjListVM.self) private var vm
    
    private var dependencies: [PackageDependency] {
        let packageProjectPairs = vm.projects.flatMap { proj in
            proj.packages.map { package in
                (package: package, project: proj)
            }
        }
        
        let grouped = Dictionary(grouping: packageProjectPairs, by: \.package.name)
        
        let packageDependencies = grouped.map { name, pairs -> PackageDependency in
            let package = pairs.first!.package
            let associatedProjects = pairs.map(\.project)
            
            return PackageDependency(
                package: package,
                proj: associatedProjects
            )
        }
        
        return packageDependencies.sorted {
            $0.useCount > $1.useCount
        }
    }
    
    var body: some View {
        List {
            ForEach(dependencies) { package in
                HStack {
                    Text(package.name)
                    
                    Spacer()
                    
                    Text(package.useCount)
                        .secondary()
                }
            }
        }
    }
}

#Preview {
    PackageDependenciesList()
}
