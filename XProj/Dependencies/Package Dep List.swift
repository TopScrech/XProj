import SwiftUI

struct PackageDepList: View {
    @Environment(ProjListVM.self) private var vm
    
    @AppStorage("sort_package_dependencies_by_author") private var sortByAuthor = true
    
    var body: some View {
        List {
            Section {
                Toggle("Sort by Author", isOn: $sortByAuthor)
            }
            
            if sortByAuthor {
                ForEach(dependenciesGroupedByAuthor, id: \.author) { group in
                    Section {
                        // Author's packages
                        ForEach(group.dependencies) { package in
                            PackageDepCard(package)
                        }
                    } header: {
                        HStack {
                            Text(group.author)
                                .headline()
                            
                            Spacer()
                            
                            Text(group.totalUsage)
                                .subheadline(.bold)
                                .secondary()
                        }
                    }
                }
            } else {
                ForEach(dependencies) { package in
                    PackageDepCard(package)
                }
            }
        }
    }
    
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
                projects: associatedProjects
            )
        }
        
        return packageDependencies.sorted {
            $0.useCount > $1.useCount
        }
    }
    
    private var dependenciesGroupedByAuthor: [(author: String, dependencies: [PackageDependency], totalUsage: Int)] {
        // Group by author
        let grouped = dependencies.reduce(into: [String: [PackageDependency]]()) { dict, dependency in
            let author = dependency.author ?? "Unknown Author"
            dict[author, default: []].append(dependency)
        }
        
        // Map to tuples with total usage
        let groupedWithUsage = grouped.map { author, dependencies -> (author: String, dependencies: [PackageDependency], totalUsage: Int) in
            let totalUsage = dependencies.reduce(0) {
                $0 + $1.useCount
            }
            
            return(
                author: author,
                dependencies: dependencies,
                totalUsage: totalUsage
            )
        }
        
        // Sort by totalUsage
        let sortedGrouped = groupedWithUsage.sorted {
            $0.totalUsage > $1.totalUsage
        }
        
        return sortedGrouped
    }
}

#Preview {
    PackageDepList()
        .environment(ProjListVM())
}
