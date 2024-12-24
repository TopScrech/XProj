// The content view for the two-column nav split view experience

import SwiftUI

struct TwoColumnContainer: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        @Bindable var nav = nav
#warning("Finish, compare to 3 ColumnView")
        NavigationSplitView(
            columnVisibility: $nav.columnVisibility
        ) {
            TwoColumnSidebar()
        } detail: {
            TwoColumnDetail()
        }
    }
}

#Preview() {
    TwoColumnContainer()
        .environment(NavModel.shared)
}
