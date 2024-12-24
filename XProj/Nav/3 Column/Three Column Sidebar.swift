import SwiftUI

struct ThreeColumnSidebar: View {
    @Environment(NavModel.self) private var nav
    
    private let categories = ProjType.projTypes
    
    var body: some View {
        @Bindable var nav = nav
        
#warning("Categories with platforms")
#warning("Category with PublishedProjectsList")
        List(selection: $nav.selectedCategory) {
            Section {
                let type = ProjType.allItems
                
                NavigationLink(value: type) {
                    Label(type.localizedName, systemImage: type.icon)
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
                let type = ProjType.packageDependencies
                
                NavigationLink(value: type) {
                    Label(type.localizedName, systemImage: type.icon)
                }
            }
            
            Section {
                let type = ProjType.derivedData
                
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
    ThreeColumnSidebar()
        .environment(NavModel.shared)
}
