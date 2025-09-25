import SwiftUI

struct ColumnSidebar: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    
    private let categories = NavCategory.projTypes
    
    var body: some View {
        @Bindable var nav = nav
        
#warning("Categories with platforms")
#warning("Category with PublishedProjectsList")
        
        //        iOS
        //        macOS
        //        watchOS
        //        tvOS
        //        visionOS
        //        Widgets
        //        iMessage
        //        Tests
        //        App Store
        //        SmartScan
        
        List(selection: $nav.selectedCategory) {
            Section {
                let type = NavCategory.allItems
                
                NavigationLink(value: type) {
                    Label(type.loc, systemImage: type.icon)
                        .bold()
                }
            }
            
            Section {
                ForEach(categories) { type in
                    if !vm.projects(in: type).isEmpty {
                        NavigationLink(value: type) {
                            Label(type.loc, systemImage: type.icon)
                        }
                    }
                }
                
                NavigationLink(value: NavCategory.appStore) {
                    Label(NavCategory.appStore.loc, systemImage: NavCategory.appStore.icon)
                }
            }
            
            //            Section {
            //                let projects = vm.projects.filter {
            //                    $0.targets.contains(where: { $0.type == .iMessage })
            //                }
            //
            //                ForEach(projects) { proj in
            //                    NavigationLink(value: type) {
            //                        Label("iMessage", systemImage: "message.badge")
            //                    }
            //                }
            //            }
            
            Section {
                let type = NavCategory.packageDependencies
                
                NavigationLink(value: type) {
                    Label(type.loc, systemImage: type.icon)
                }
            }
            
            Section {
                let type = NavCategory.derivedData
                
                NavigationLink(value: type) {
                    Label(type.loc, systemImage: type.icon)
                }
            }
        }
        .navigationTitle("Categories")
        .frame(minWidth: 250)
        .padding(.vertical)
    }
}

#Preview {
    ColumnSidebar()
        .darkSchemePreferred()
        .environment(NavModel.shared)
}

