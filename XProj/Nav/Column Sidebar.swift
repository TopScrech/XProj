import SwiftUI

struct ColumnSidebar: View {
    @Environment(NavModel.self) private var nav
    
    private let categories = NavCategory.projTypes
    
    var body: some View {
        @Bindable var nav = nav
        
#warning("Categories with platforms")
#warning("Category with PublishedProjectsList")
        List(selection: $nav.selectedCategory) {
            Section {
                let type = NavCategory.allItems
                
                NavigationLink(value: type) {
                    Label(type.localizedName, systemImage: type.icon)
                        .bold()
                }
            }
            
            Section {
                ForEach(categories) { type in
                    NavigationLink(value: type) {
                        Label(type.localizedName, systemImage: type.icon)
                    }
                }
            }
            
            Section {
                let type = NavCategory.packageDependencies
                
                NavigationLink(value: type) {
                    Label(type.localizedName, systemImage: type.icon)
                }
            }
            
            Section {
                let type = NavCategory.derivedData
                
                NavigationLink(value: type) {
                    Label(type.localizedName, systemImage: type.icon)
                }
            }
        }
        .frame(minWidth: 250)
        .navigationTitle("Categories")
    }
}

#Preview {
    ColumnSidebar()
        .environment(NavModel.shared)
}
