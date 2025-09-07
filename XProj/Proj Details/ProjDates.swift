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
                
                Text(formattedDateAndTime(proj.openedAt))
            }
            
            if let modifiedAt = proj.modifiedAt {
                HStack(spacing: 0) {
                    Text("Modified: ")
                        .secondary()
                    
                    Text(formattedDateAndTime(modifiedAt))
                }
            }
            
            if let createdAt = proj.createdAt {
                HStack(spacing: 0) {
                    Text("Created: ")
                        .secondary()
                    
                    Text(formattedDateAndTime(createdAt))
                }
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    ProjDates(previewProj1)
}
