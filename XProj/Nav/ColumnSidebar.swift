import SwiftUI

struct ColumnSidebar: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    
    private let categories = NavCategory.projTypes
    private let platformCategories = NavCategory.projPlatforms
    
    var body: some View {
        @Bindable var nav = nav
        
        List(selection: $nav.selectedCategory) {
            Section {
                let type = NavCategory.allItems
                
                NavigationLink(value: type) {
                    Label(type.loc, systemImage: type.icon)
                        .bold()
                }
            }

            Section {
                let type = NavCategory.favorites

                NavigationLink(value: type) {
                    Label(type.loc, systemImage: type.icon)
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
            }
            
            Section {
                ForEach(platformCategories) { type in
                    NavigationLink(value: type) {
                        Label(type.loc, systemImage: type.icon)
                    }
                }
            }
            
            Section {
                let type = NavCategory.appStore
                
                NavigationLink(value: type) {
                    Label(type.loc, systemImage: type.icon)
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
