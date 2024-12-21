// The content view for the two-column nav split view experience

import SwiftUI

struct TwoColumnContainer: View {
    @Environment(NavigationModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = Category.allCases
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            List(categories, selection: $nav.selectedCategory) { category in
                NavigationLink(category.localizedName, value: category)
            }
            .navigationTitle("Categories")
        } detail: {
            NavigationStack(path: $nav.recipePath) {
                RecipeGrid()
            }
            .experienceToolbar()
        }
    }
}

#Preview() {
    TwoColumnContainer()
        .environment(DataModel.shared)
        .environment(NavigationModel.shared)
}
