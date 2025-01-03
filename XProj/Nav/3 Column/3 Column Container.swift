import SwiftUI

struct ThreeColumnContainer: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationSplitView(columnVisibility: $nav.columnVisibility) {
            ColumnSidebar()
        } content: {
            ThreeColumnContent()
        } detail: {
            ThreeColumnDetail()
        }
        .toolbar {
            Button("Open") {
                if let proj = nav.selectedProj.first {
                    dataModel.openProj(proj)
                } else {
                    dataModel.openProjects(nav.selectedProj)
                }
            }
            .keyboardShortcut(.init("O", modifiers: .command))
            .opacity(0)
            .disabled(nav.selectedProj.count == 0)
            
            Button("Open") {
                if let proj = nav.selectedProj.first {
                    dataModel.openProj(proj)
                } else {
                    dataModel.openProjects(nav.selectedProj)
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
