import SwiftUI

struct SidebarView: View {
    var body: some View {
        List {
            NavigationLink("All") {
                ProjList()
            }
            .padding(.vertical)
            
            NavigationLink {
                ProjList()
            } label: {
                Label("Projects", systemImage: "hammer")
            }
            
            NavigationLink {
                ProjList()
            } label: {
                Label("Swift Packages", systemImage: "shippingbox")
            }
        }
        .padding(.top)
        .frame(width: 215)
        //        .toolbar(removing: .sidebarToggle)
    }
}

#Preview {
    SidebarView()
}