import SwiftUI

struct HomeView: View {
    @Environment(ProjListVM.self) private var vm
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            SidebarView()
                .frame(minWidth: 250)
        } content: {
            ProjList(vm.filteredProjects)
                .frame(minWidth: 500)
        } detail: {
            Text("Details")
                .frame(minWidth: 200, maxWidth: 500)
        }
        
        //            NavigationLink("Derived Data") {
        //                DerivedDataList()
        //            }
    }
}

#Preview {
    HomeView()
}
