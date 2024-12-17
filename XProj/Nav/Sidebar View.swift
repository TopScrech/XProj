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
            
            NavigationLink {
                ProjList(vm.projects.filter {
                    $0.uniquePlatforms.contains("iOS")
                })
            } label: {
                Label("iOS", systemImage: "iphone")
            }
            
            NavigationLink {
                ProjList(vm.projects.filter {
                    $0.uniquePlatforms.contains("macOS")
                })
            } label: {
                Label("macOS", systemImage: "macbook")
            }
            
            NavigationLink {
                ProjList(vm.projects.filter {
                    $0.uniquePlatforms.contains("watchOS")
                })
            } label: {
                Label("tvOS", systemImage: "tv")
            }
            
            NavigationLink {
                ProjList(vm.projects.filter {
                    $0.uniquePlatforms.contains("tvOS")
                })
            } label: {
                Label("tvOS", systemImage: "tv")
            }
            
            NavigationLink {
                ProjList(vm.projects.filter {
                    $0.uniquePlatforms.contains("visionOS")
                })
            } label: {
                Label("visionOS", systemImage: "vision.pro")
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
