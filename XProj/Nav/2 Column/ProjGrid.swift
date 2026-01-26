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
                            projLink(proj)
                        }
                    }
                    .padding()
                }
                .navigationTitle(category.loc)
                .navigationDestination(for: Proj.self) {
                    ProjDetails($0)
                }

            case .favorites:
                if dataModel.favoriteProjects.isEmpty {
                    Text("No favorites yet")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .navigationTitle(category.loc)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(dataModel.favoriteProjects) { proj in
                                projLink(proj)
                            }
                        }
                        .padding()
                    }
                    .navigationTitle(category.loc)
                    .navigationDestination(for: Proj.self) {
                        ProjDetails($0)
                    }
                }
                
            case .derivedData:
                DerivedDataList()
                
            case .packageDependencies:
                DependencyList()
                
            case .appStore:
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(dataModel.publishedProjects) { proj in
                            projLink(proj)
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
                            projLink(proj)
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
                            projLink(proj)
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

    private func projLink(_ proj: Proj) -> some View {
        NavigationLink(value: proj) {
            ProjGridItem(proj)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(
                dataModel.isFavorite(proj) ? "Remove Favorite" : "Add Favorite",
                systemImage: dataModel.isFavorite(proj) ? "star.slash" : "star"
            ) {
                dataModel.toggleFavorite(proj)
            }
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
