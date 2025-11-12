import SwiftUI

struct BottomBar: View {
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        if !vm.projects.isEmpty {
            Text("Projects: \(vm.projectCount) • Swift Packages: \(vm.packageCount) • Vapor: \(vm.vaporCount) • Playgrounds: \(vm.playgroundCount) • Workspaces: \(vm.workspaceCount)")
                .secondary()
                .lineLimit(2)
                .padding(.bottom, 5)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    BottomBar()
        .darkSchemePreferred()
        .environment(DataModel())
}
