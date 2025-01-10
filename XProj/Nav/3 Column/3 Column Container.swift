import SwiftUI

struct ThreeColumnContainer: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            ColumnSidebar()
        } content: {
            VStack {
                ThreeColumnContent()
                
                BottomBar()
            }
        } detail: {
            ThreeColumnDetail()
        }
        .toolbar {
            OpenButtons()
        }
    }
}

#Preview() {
    ThreeColumnContainer()
        .environment(NavModel(columnVisibility: .all))
        .environment(DataModel.shared)
}
