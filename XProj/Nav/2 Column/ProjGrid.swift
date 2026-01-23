import SwiftUI

struct ProjGrid: View {
    @Environment(NavModel.self) private var navModel
    @Environment(DataModel.self) private var dataModel
    
    private let columns = [
        GridItem(.adaptive(minimum: 240))
    ]
    
    var body: some View {
        if let category = navModel.selectedCategory {
            switch category {
            case .allItems:
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(dataModel.filteredProjects) { proj in
                            NavigationLink(value: proj) {
                                ProjGridItem(proj)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .navigationTitle(category.loc)
                .navigationDestination(for: Proj.self) {
                    ProjDetails($0)
                }
                
            case .derivedData:
                DerivedDataList()
                
            case .packageDependencies:
                DependencyList()
                
            case .appStore:
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(dataModel.publishedProjects) { proj in
                            NavigationLink(value: proj) {
                                ProjGridItem(proj)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .navigationTitle(category.loc)
                .navigationDestination(for: Proj.self) {
                    ProjDetails($0)
                }
                .task(id: dataModel.projectsFolder) {
                    await dataModel.loadAppStoreProjectsIfNeeded()
                }

            case .iOS, .macOS, .watchOS, .tvOS, .visionOS:
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(dataModel.projects(in: category)) { proj in
                            NavigationLink(value: proj) {
                                ProjGridItem(proj)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .navigationTitle(category.loc)
                .navigationDestination(for: Proj.self) {
                    ProjDetails($0)
                }
                .task(id: dataModel.projectsFolder) {
                    await dataModel.loadPlatformProjectsIfNeeded()
                }

            default:
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(dataModel.projects(in: category)) { proj in
                            NavigationLink(value: proj) {
                                ProjGridItem(proj)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .navigationTitle(category.loc)
                .navigationDestination(for: Proj.self) {
                    ProjDetails($0)
                }
            }
        } else {
            Text("Choose a category")
                .navigationTitle("")
        }
    }
}

#Preview {
    ProjGrid()
        .darkSchemePreferred()
        .environment(DataModel.shared)
        .environment(NavModel(selectedCategory: .proj))
}

#Preview {
    ProjGrid()
        .darkSchemePreferred()
        .environment(DataModel.shared)
        .environment(NavModel(selectedCategory: nil))
}
