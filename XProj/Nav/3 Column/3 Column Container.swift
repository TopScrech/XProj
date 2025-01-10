import SwiftUI

struct ThreeColumnContainer: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    
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
            Button("Open") {
                if let proj = nav.selectedProj.first {
                    vm.openProj(proj)
                } else {
                    vm.openProjects(nav.selectedProj)
                }
            }
            .keyboardShortcut(.init("O", modifiers: .command))
            .opacity(0)
            .disabled(nav.selectedProj.count == 0)
            
            Button("Open") {
                if let proj = nav.selectedProj.first {
                    vm.openProj(proj)
                } else {
                    vm.openProjects(nav.selectedProj)
                }
            }
            .keyboardShortcut(.defaultAction)
            .opacity(0)
            .disabled(nav.selectedProj.count == 0)
        }
    }
}

#Preview() {
    ThreeColumnContainer()
        .environment(NavModel(columnVisibility: .all))
        .environment(DataModel.shared)
}
