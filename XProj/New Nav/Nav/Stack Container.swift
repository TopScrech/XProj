// The content view for the nav stack view experience

import SwiftUI

struct StackContainer: View {
    @Environment(NavigationModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = ProjType.allCases
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.recipePath) {
            List(categories) { category in
                Section {
                    ForEach(dataModel.recipes(in: category)) { recipe in
                        NavigationLink(recipe.name, value: recipe)
                    }
                } header: {
                    Text(category.localizedName)
                }
            }
            .navigationTitle("Categories")
            .experienceToolbar()
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetail(recipe) { relatedRecipe in
                    Button {
                        nav.recipePath.append(relatedRecipe)
                    } label: {
                        RecipeTile(relatedRecipe)
                    }
                    .buttonStyle(.plain)
                }
                .experienceToolbar()
            }
        }
    }
}

#Preview() {
    StackContainer()
        .environment(DataModel.shared)
        .environment(NavigationModel.shared)
}
