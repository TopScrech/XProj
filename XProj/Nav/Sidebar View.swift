import SwiftUI

struct SidebarView: View {
    @Environment(ProjListVM.self) private var vm
    
    var body: some View {
        List {
            NavigationLink("All") {
                ProjList(vm.filteredProjects)
            }
            .padding(.vertical)
            
            NavigationLink {
                OnlyProjList()
            } label: {
                Label("Projects", systemImage: "hammer")
            }
            
            NavigationLink {
                OnlyPackageList()
            } label: {
                Label("Swift Packages", systemImage: "shippingbox")
            }
            
            Spacer()
            
            NavigationLink("Derived data") {
                DerivedDataList()
            }
        }
        .padding(.top)
        //        .toolbar(removing: .sidebarToggle)
    }
}

#Preview {
    SidebarView()
}