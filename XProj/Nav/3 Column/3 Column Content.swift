import SwiftUI

struct ThreeColumnContent: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        @Bindable var nav = nav
        
        if let category = nav.selectedCategory {
            switch category {
            case .allItems:
                List(selection: $nav.selectedProj) {
                    ForEach(vm.filteredProjects) { proj in
                        NavigationLink(value: proj) {
                            ProjCard(proj)
                        }
                    }
                }
                .frame(minWidth: 600)
                .navigationTitle(category.loc)

            case .favorites:
                if vm.favoriteProjects.isEmpty {
                    Text("No favorites yet")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .navigationTitle(category.loc)
                } else {
                    List(selection: $nav.selectedProj) {
                        ForEach(vm.favoriteProjects) { proj in
                            NavigationLink(value: proj) {
                                ProjCard(proj)
                            }
                        }
                    }
                    .frame(minWidth: 600)
                    .navigationTitle(category.loc)
                }
                
            case .derivedData:
                DerivedDataList()
                
            case .packageDependencies:
                DependencyList()
                
            case .appStore:
                List(selection: $nav.selectedProj) {
                    ForEach(vm.publishedProjects) { proj in
                        NavigationLink(value: proj) {
                            ProjCard(proj)
                        }
                    }
                }
                .frame(minWidth: 600)
                .navigationTitle(category.loc)
                .task(id: vm.projectsFolder) {
                    await vm.loadAppStoreProjectsIfNeeded()
                }

            case .iOS, .macOS, .watchOS, .tvOS, .visionOS:
                List(selection: $nav.selectedProj) {
                    ForEach(vm.projects(in: category)) { proj in
                        NavigationLink(value: proj) {
                            ProjCard(proj)
                        }
                    }
                }
                .frame(minWidth: 600)
                .navigationTitle(category.loc)
                .task(id: vm.projectsFolder) {
                    await vm.loadPlatformProjectsIfNeeded()
                }

            default:
                List(selection: $nav.selectedProj) {
                    ForEach(vm.projects(in: category)) { proj in
                        NavigationLink(value: proj) {
                            ProjCard(proj)
                        }
                    }
                }
                .frame(minWidth: 600)
                .navigationTitle(category.loc)
            }
        } else {
            Text("Choose a category")
                .navigationTitle("")
        }
    }
}

#Preview {
    ThreeColumnContent()
        .darkSchemePreferred()
        .environment(NavModel.shared)
        .environment(DataModel.shared)
}
