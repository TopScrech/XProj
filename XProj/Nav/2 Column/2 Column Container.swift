import SwiftUI

struct TwoColumnContainer: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        @Bindable var nav = nav
        NavigationSplitView(
            columnVisibility: $nav.columnVisibility
        ) {
            ColumnSidebar()
        } detail: {
            VStack {
                TwoColumnDetail()
                
                BottomBar()
            }
        }
    }
}

#Preview() {
    TwoColumnContainer()
        .environment(NavModel.shared)
}
