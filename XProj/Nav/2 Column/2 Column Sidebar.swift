import SwiftUI

struct TwoColumnSidebar: View {
    @Environment(NavModel.self) private var nav
    
    private let categories = ProjType.projTypes
    
    var body: some View {
        @Bindable var nav = nav
        
        List(selection: $nav.selectedCategory) {
            ForEach(categories) { type in
                NavigationLink(type.localizedName, value: type)
            }
            
            Section {
                NavigationLink("Derived Data", value: ProjType.derivedData)
            }
        }
        .navigationTitle("Categories")
    }
}

#Preview {
    TwoColumnSidebar()
        .environment(NavModel.shared)
}
