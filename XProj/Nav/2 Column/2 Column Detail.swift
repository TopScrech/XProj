import SwiftUI

struct TwoColumnDetail: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.projPath) {
            if nav.selectedCategory == .derivedData {
                DerivedDataList()
            } else {
                ProjGrid()
            }
        }
    }
}

#Preview {
    TwoColumnDetail()
        .darkSchemePreferred()
        .environment(NavModel.shared)
}
