import SwiftUI

struct ThreeColumnContainer: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        @Bindable var nav = nav
        @Bindable var vm = vm
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            ColumnSidebar()
        } content: {
            VStack {
                ThreeColumnContent()
                
                BottomBar()
            }
        } detail: {
            ThreeColumnDetail()
                .frame(minWidth: 200)
        }
        .searchable(text: $vm.searchPrompt)
        .searchSuggestions {
            SearchSuggestions()
        }
        .toolbar {
            OpenButtons()
        }
    }
}

#Preview {
    ThreeColumnContainer()
        .environment(NavModel(columnVisibility: .all))
        .environment(DataModel.shared)
}
