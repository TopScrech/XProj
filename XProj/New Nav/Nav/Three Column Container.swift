import SwiftUI

struct ThreeColumnContainer: View {
    @Environment(ProjListVM.self) private var vm
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
                List(selection: $nav.selectedRecipe) {
                    ForEach(dataModel.recipes(in: category)) { recipe in
                        NavigationLink(recipe.name, value: recipe)
                    }
                }
                .navigationTitle(category.localizedName)
                .onDisappear {
                    nav.selectedCategory = nil
                }
                .experienceToolbar()
            } else {
                Text("Choose a category")
                    .navigationTitle("")
            }
        } detail: {
            Button("Clear nav") {
                nav.prochistitZalupu()
            }
            
            if let selectedRecipe = nav.selectedRecipe.first {
                Text("Seleted \(nav.selectedRecipe.count)")
                
                RecipeDetail(selectedRecipe) { relatedRecipe in
                    Button {
                        nav.selectedCategory = relatedRecipe.type
                        nav.selectedRecipe = Set([relatedRecipe])
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
        .environment(ProjListVM())
}
