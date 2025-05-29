import SwiftUI

struct OpenButtons: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        Group {
            Button("Open") {
                vm.openProjects(nav.selectedProj)
            }
            .keyboardShortcut("O")
            
            Button("Open") {
                vm.openProjects(nav.selectedProj)
            }
            .keyboardShortcut(.defaultAction)
        }
        .opacity(0)
        .disabled(nav.selectedProj.count == 0)
    }
}

#Preview {
    OpenButtons()
        .environment(NavModel.shared)
        .environment(DataModel.shared)
}
