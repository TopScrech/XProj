//import SwiftUI
//
//struct SidebarView: View {
//    @Environment(DataModel.self) private var vm
//    
//    var body: some View {
//        List {
//            NavigationLink("All") {
//                ProjList(vm.filteredProjects)
//            }
//
//            Spacer()
//            
//            NavigationLink {
//                ProjList(vm.filteredProjects.filter {
//                    $0.platforms.contains("iOS")
//                })
//            } label: {
//                Label("iOS", systemImage: "iphone")
//            }
//            
//            NavigationLink {
//                ProjList(vm.filteredProjects.filter {
//                    $0.platforms.contains("macOS")
//                })
//            } label: {
//                Label("macOS", systemImage: "macbook")
//            }
//            
//            NavigationLink {
//                ProjList(vm.filteredProjects.filter {
//                    $0.platforms.contains("watchOS")
//                })
//            } label: {
//                Label("watchOS", systemImage: "applewatch")
//            }
//            
//            NavigationLink {
//                ProjList(vm.filteredProjects.filter {
//                    $0.platforms.contains("tvOS")
//                })
//            } label: {
//                Label("tvOS", systemImage: "tv")
//            }
//            
//            NavigationLink {
//                ProjList(vm.filteredProjects.filter {
//                    $0.platforms.contains("visionOS")
//                })
//            } label: {
//                Label("visionOS", systemImage: "vision.pro")
//            }
//            
//            NavigationLink {
//                ProjList(vm.filteredProjects.filter {
//                    $0.targets.contains {
//                        $0.type == .widgets
//                    }
//                })
//            } label: {
//                Label("Widgets", systemImage: "widget.large")
//            }
//            
//            NavigationLink {
//                ProjList(vm.filteredProjects.filter {
//                    $0.targets.contains {
//                        $0.type == .iMessage
//                    }
//                })
//            } label: {
//                Label("iMessage", systemImage: "message.badge")
//            }
//            
//            NavigationLink {
//                ProjList(vm.filteredProjects.filter {
//                    $0.targets.contains {
//                        $0.type == .unitTests || $0.type == .uiTests
//                    }
//                })
//            } label: {
//                Label("Tests", systemImage: "testtube.2")
//            }
//            
//            Spacer()
//            
//            PublichesProjectsList()
//            
//            NavigationLink {
//                PackageDepList()
//            } label: {
//                Label("Package dependencies", systemImage: "shippingbox")
//            }
//            
//            Spacer()
//            
//            NavigationLink("Derived data") {
//                DerivedDataList()
//            }
//            
//            Spacer()
//            
//            SmartScan()
//        }
//        .padding(.top)
//        //        .toolbar(removing: .sidebarToggle)
//    }
//}
//
//#Preview {
//    SidebarView()
//        .environment(DataModel.shared)
//}
