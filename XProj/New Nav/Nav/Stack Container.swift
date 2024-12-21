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
            .navigationDestination(for: Recipe.self) { proj in
                RecipeDetail(proj) { relatedProj in
                    Button {
                        nav.recipePath.append(relatedProj)
                    } label: {
                        RecipeTile(relatedProj)
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
