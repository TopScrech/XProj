// A grid of proj tiles, based on a given category

import SwiftUI

struct ProjGrid: View {
    @Environment(NavModel.self) private var navModel
    @Environment(DataModel.self) private var dataModel
    
    var body: some View {
        if let category = navModel.selectedCategory {
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
            .navigationTitle(category.localizedName)
            .navigationDestination(for: Proj.self) { proj in
                ProjDetails(proj)
                
                //                RecipeDetail(proj) { relatedProj in
                //                    Button {
                //                        navModel.projPath.append(relatedProj)
                //                    } label: {
                //                        RecipeTile(relatedProj)
                //                    }
                //                    .buttonStyle(.plain)
                //                }
            }
        } else {
            Text("Choose a category")
                .navigationTitle("")
        }
    }
    
    var columns: [GridItem] {[
        GridItem(.adaptive(minimum: 240))
    ]}
}

#Preview() {
    ProjGrid()
        .environment(DataModel.shared)
        .environment(NavModel(selectedCategory: .proj))
}

#Preview() {
    ProjGrid()
        .environment(DataModel.shared)
        .environment(NavModel(selectedCategory: nil))
}
