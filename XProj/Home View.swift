import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            SidebarView()
                .frame(minWidth: 250)
        } content: {
            ProjList()
        } detail: {
            Text("Detail")
        }
        //            NavigationLink("Derived Data") {
        //                DerivedDataList()
        //            }
    }
}

#Preview {
    HomeView()
}
