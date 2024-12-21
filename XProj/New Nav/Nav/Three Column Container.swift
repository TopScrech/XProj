import SwiftUI

struct ThreeColumnContainer: View {
    @Environment(NavigationModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = ProjType.allCases
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            List(categories, selection: $nav.selectedCategory) { type in
                NavigationLink(type.localizedName, value: type)
            }
            .navigationTitle("Categories")
        } content: {
            if let category = nav.selectedCategory {
                List(selection: $nav.selectedProj) {
                    ForEach(dataModel.recipes(in: category)) { recipe in
                        NavigationLink(recipe.name, value: recipe)
                    }
                }
                .navigationTitle(category.localizedName)
                .experienceToolbar()
                .onDisappear {
                    nav.selectedCategory = nil
                }
            } else {
                Text("Choose a category")
                    .navigationTitle("")
            }
        } detail: {
            if let selectedRecipe = nav.selectedProj.first {
                Text("Seleted \(nav.selectedProj.count)")
                
                RecipeDetail(selectedRecipe) { relatedRecipe in
                    Button {
                        nav.selectedCategory = relatedRecipe.type
                        nav.selectedProj = Set([relatedRecipe])
                    } label: {
                        RecipeTile(relatedRecipe)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview() {
    ThreeColumnContainer()
        .environment(NavigationModel(columnVisibility: .all))
        .environment(DataModel.shared)
}
