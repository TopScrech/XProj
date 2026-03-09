import SwiftUI

struct ThreeColumnContainer: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    @Environment(DerivedDataVM.self) private var derivedDataVM
    
    var body: some View {
        @Bindable var nav = nav
        @Bindable var vm = vm
        @Bindable var derivedDataVM = derivedDataVM
        let searchText = nav.selectedCategory == .derivedData ? $derivedDataVM.searchPrompt : $vm.searchPrompt
        
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
        .searchable(text: searchText)
        .searchSuggestions {
            if nav.selectedCategory != .derivedData {
                SearchSuggestions()
            }
        }
        .toolbar {
            OpenButtons()
#if DEBUG
            ProjListToolbar()
#endif
        }
        .onChange(of: nav.selectedCategory) { _, newValue in
            if newValue == .derivedData {
                vm.searchPrompt = ""
            } else {
                derivedDataVM.searchPrompt = ""
            }
        }
    }
}

#Preview {
    ThreeColumnContainer()
        .darkSchemePreferred()
        .environment(DataModel.shared)
        .environment(NavModel(columnVisibility: .all))
}
