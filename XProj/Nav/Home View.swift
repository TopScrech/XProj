import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            SidebarView()
                .frame(minWidth: 250)
        } content: {
            ProjList()
                .frame(minWidth: 500)
        } detail: {
            Text("Detail")
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
