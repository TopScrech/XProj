import SwiftUI

struct ProjDates: View {
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ProjDate("Last opened: ", date: proj.openedAt)
            ProjDate("Modified: ", date: proj.modifiedAt)
            ProjDate("Created: ", date: proj.createdAt)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    ProjDates(PreviewProp.previewProj1)
        .darkSchemePreferred()
}
