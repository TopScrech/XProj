import SwiftUI

struct ThreeColumnDetail: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        if nav.selectedProj.count == 1, let proj = nav.selectedProj.first {
            ProjDetails(proj)
                .frame(minWidth: 200)
        } else {
            Text("Multiple projects selected")
        }
    }
}

#Preview {
    ThreeColumnDetail()
        .environment(NavModel.shared)
}
