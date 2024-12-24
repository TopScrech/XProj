// The content view for the two-column nav split view experience

import SwiftUI

struct TwoColumnContainer: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    private let categories = ProjType.projTypes
    
    var body: some View {
        @Bindable var nav = nav
        #warning("Finish, compare to 3 ColumnView")
        NavigationSplitView(
            columnVisibility: $nav.columnVisibility
        ) {
            List(selection: $nav.selectedCategory) {
                ForEach(categories) { type in
                    NavigationLink(type.localizedName, value: type)
                }
                
                Section {
                    NavigationLink("Derived Data", value: ProjType.derivedData)
                }
            }
            .navigationTitle("Categories")
        } detail: {
            NavigationStack(path: $nav.projPath) {
                if nav.selectedCategory == .derivedData {
                    DerivedDataList()
                } else {
                    ProjGrid()
                }
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
