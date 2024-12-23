// The content view for the two-column nav split view experience

import SwiftUI

struct TwoColumnContainer: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = ProjType.allCases
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            List(categories, selection: $nav.selectedCategory) { type in
                NavigationLink(type.localizedName, value: type)
            }
            .navigationTitle("Categories")
        } detail: {
            NavigationStack(path: $nav.projPath) {
                ProjGrid()
            }
            .experienceToolbar()
        }
    }
}

#Preview() {
    TwoColumnContainer()
        .environment(DataModel.shared)
        .environment(NavModel.shared)
}
