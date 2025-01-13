import SwiftUI

struct TwoColumnContainer: View {
    @Environment(DataModel.self) private var vm
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        @Bindable var nav = nav
        @Bindable var vm = vm
        
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
        .searchable(text: $vm.searchPrompt)
        .searchSuggestions {
            SearchSuggestions()
        }
        .toolbar {
            OpenButtons()
        }
    }
}

#Preview() {
    TwoColumnContainer()
        .environment(NavModel.shared)
}
