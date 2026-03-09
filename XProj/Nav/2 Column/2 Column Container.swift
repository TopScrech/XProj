import SwiftUI

struct TwoColumnContainer: View {
    @Environment(DataModel.self) private var vm
    @Environment(NavModel.self) private var nav
    @Environment(DerivedDataVM.self) private var derivedDataVM
    
    var body: some View {
        @Bindable var nav = nav
        @Bindable var vm = vm
        @Bindable var derivedDataVM = derivedDataVM
        let searchText = nav.selectedCategory == .derivedData ? $derivedDataVM.searchPrompt : $vm.searchPrompt
        
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
        .searchable(text: searchText)
        .searchSuggestions {
            if nav.selectedCategory != .derivedData {
                SearchSuggestions()
            }
        }
        .toolbar {
            OpenButtons()
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
    TwoColumnContainer()
        .darkSchemePreferred()
        .environment(NavModel.shared)
        .environment(DataModel.shared)
}
