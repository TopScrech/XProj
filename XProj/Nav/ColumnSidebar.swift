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
                let all = NavCategory.allItems
                
                NavigationLink(value: all) {
                    Label(all.loc, systemImage: all.icon)
                        .bold()
                }
                
                let favorites = NavCategory.favorites
                
                NavigationLink(value: favorites) {
                    Label(favorites.loc, systemImage: favorites.icon)
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
