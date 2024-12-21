import SwiftUI

struct HomeView: View {
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            SidebarView()
                .frame(minWidth: 250)
        } content: {
            ProjList(vm.filteredProjects)
                .frame(minWidth: 600)
        } detail: {
            Text("Details")
                .frame(minWidth: 200, maxWidth: 500)
        }
    }
}

#Preview {
    HomeView()
        .environment(DataModel())
}
