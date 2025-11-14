import SwiftUI

struct ProjDates: View {
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 0) {
                Text("Last opened: ")
                    .secondary()
                
                Text(DateFormatters.formattedDateAndTime(proj.openedAt))
            }
            
            if let modifiedAt = proj.modifiedAt {
                HStack(spacing: 0) {
                    Text("Modified: ")
                        .secondary()
                    
                    Text(DateFormatters.formattedDateAndTime(modifiedAt))
                }
            }
            
            if let createdAt = proj.createdAt {
                HStack(spacing: 0) {
                    Text("Created: ")
                        .secondary()
                    
                    Text(DateFormatters.formattedDateAndTime(createdAt))
                }
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    ProjDates(PreviewProp.previewProj1)
        .darkSchemePreferred()
}
