import SwiftUI

struct OpenButtons: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        if #available(macOS 15, *) {
            Button("Open") {
                vm.openProjects(nav.selectedProj)
            }
            .keyboardShortcut("O")
            .toolbarItemHidden()
            .disabled(nav.selectedProj.count == 0)
        } else {
            Button("Open") {
                vm.openProjects(nav.selectedProj)
            }
            .keyboardShortcut("O")
            .opacity(0)
            .disabled(nav.selectedProj.count == 0)
        }
    }
}

#Preview {
    OpenButtons()
        .environment(NavModel.shared)
        .environment(DataModel.shared)
}
