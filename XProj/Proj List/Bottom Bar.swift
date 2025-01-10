import SwiftUI

struct BottomBar: View {
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        Text("Projects: \(vm.projectCount) • Swift Packages: \(vm.packageCount) • Vapor: \(vm.vaporCount) • Playgrounds: \(vm.playgroundCount) • Workspaces: \(vm.workspaceCount)")
            .secondary()
            .padding(.bottom, 5)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
    }
}

#Preview {
    BottomBar()
        .environment(DataModel())
}
