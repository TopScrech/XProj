import SwiftUI

struct SidebarView: View {
    var body: some View {
        List {
            NavigationLink("All") {
                ProjectList()
            }
            .padding(.vertical)
            
            NavigationLink {
                ProjectList()
            } label: {
                Label("Projects", systemImage: "hammer")
            }
            
            NavigationLink {
                ProjectList()
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
