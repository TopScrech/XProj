// A grid of recipe tiles, based on a given recipe category

import SwiftUI

struct RecipeGrid: View {
    @Environment(NavModel.self) private var navModel
    @Environment(DataModel.self) private var dataModel
    
    var body: some View {
        if let category = navModel.selectedCategory {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(dataModel.recipes(in: category)) { recipe in
                        NavigationLink(value: recipe) {
                            RecipeTile(recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle(category.localizedName)
            .navigationDestination(for: Proj.self) { proj in
                ProjDetails(proj)
                
//                RecipeDetail(proj) { relatedRecipe in
//                    Button {
//                        navModel.projPath.append(relatedRecipe)
//                    } label: {
//                        RecipeTile(relatedRecipe)
//                    }
//                    .buttonStyle(.plain)
//                }
                .experienceToolbar()
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
    RecipeGrid()
        .environment(DataModel.shared)
        .environment(NavModel(selectedCategory: .proj))
}

#Preview() {
    RecipeGrid()
        .environment(DataModel.shared)
        .environment(NavModel(selectedCategory: nil))
}
