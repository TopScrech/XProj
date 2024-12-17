import SwiftUI

struct SidebarView: View {
    @Environment(ProjListVM.self) private var vm
    
    var body: some View {
        List {
            NavigationLink("All") {
                ProjList(vm.filteredProjects)
            }
            
            Spacer()
            
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
            
            NavigationLink {
                OnlyPlaygroundsList()
            } label: {
                Label("Playgrounds", systemImage: "swift")
            }
            
            Spacer()
            
            NavigationLink("iOS") {
                ProjList(vm.projects.filter {
                    $0.uniquePlatforms.contains("iOS")
                })
            }
            
            NavigationLink("macOS") {
                ProjList(vm.projects.filter {
                    $0.uniquePlatforms.contains("macOS")
                })
            }
            
            NavigationLink("watchOS") {
                ProjList(vm.projects.filter {
                    $0.uniquePlatforms.contains("watchOS")
                })
            }
            
            NavigationLink("tvOS") {
                ProjList(vm.projects.filter {
                    $0.uniquePlatforms.contains("tvOS")
                })
            }
            
            NavigationLink("visionOS") {
                ProjList(vm.projects.filter {
                    $0.uniquePlatforms.contains("visionOS")
                })
            }
            
            Spacer()
            
            PublichesProjectsList()
            
            NavigationLink {
                PackageDepList()
            } label: {
                Label("Package dependencies", systemImage: "shippingbox")
            }
            
            Spacer()
            
            NavigationLink("Derived data") {
                DerivedDataList()
            }
            
            Spacer()
            
            SmartScan()
        }
        .padding(.top)
        //        .toolbar(removing: .sidebarToggle)
    }
}

#Preview {
    SidebarView()
}
