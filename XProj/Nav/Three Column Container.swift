import SwiftUI

struct ThreeColumnContainer: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = ProjType.projTypes
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(
            columnVisibility: $nav.columnVisibility
        ) {
#warning("Categories with platforms")
#warning("Category with PublishedProjectsList")
#warning("Category with all projects")
            List(selection: $nav.selectedCategory) {
                ForEach(categories) { type in
                    NavigationLink(type.localizedName, value: type)
                }
                
                Section {
                    NavigationLink("Package Dependencies", value: ProjType.packageDependencies)
                }
                
                Section {
                    NavigationLink("Derived Data", value: ProjType.derivedData)
                }
            }
            .frame(minWidth: 250)
            .navigationTitle("Categories")
        } content: {
            if let category = nav.selectedCategory {
                switch category {
                case .derivedData:
                    DerivedDataList()
                    
                case .packageDependencies:
                    PackageDepList()
                    
                default:
                    List(selection: $nav.selectedProj) {
                        ForEach(dataModel.projects(in: category)) { proj in
                            NavigationLink(value: proj) {
                                ProjCard(proj)
                            }
                        }
                    }
                    .frame(minWidth: 600)
                    .navigationTitle(category.localizedName)
                    .experienceToolbar()
                }
            } else {
                Text("Choose a category")
                    .navigationTitle("")
            }
        } detail: {
            if nav.selectedProj.count == 1, let proj = nav.selectedProj.first {
                ProjDetails(proj)
                    .frame(minWidth: 200)
            } else {
                
            }
            
            //                RecipeDetail(selectedProj) { relatedRecipe in
            //                    Button {
            //                        nav.selectedCategory = relatedRecipe.type
            //                        nav.selectedProj = Set([relatedRecipe])
            //                    } label: {
            //                        RecipeTile(relatedRecipe)
            //                    }
            //                    .buttonStyle(.plain)
            //                }
        }
        .toolbar {
            Button("Open") {
                if let proj = nav.selectedProj.first {
                    dataModel.openProj(proj)
                } else {
                    dataModel.openProjects(nav.selectedProj)
                }
            }
            .keyboardShortcut(.init("O", modifiers: .command))
            .opacity(0)
            .disabled(nav.selectedProj.count == 0)
            
            Button("Open") {
                if let proj = nav.selectedProj.first {
                    dataModel.openProj(proj)
                } else {
                    dataModel.openProjects(nav.selectedProj)
                }
            }
            .keyboardShortcut(.defaultAction)
            .opacity(0)
            .disabled(nav.selectedProj.count == 0)
        }
    }
}

#Preview() {
    ThreeColumnContainer()
        .environment(NavModel(columnVisibility: .all))
        .environment(DataModel.shared)
}
