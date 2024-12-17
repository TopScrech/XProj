import SwiftUI

struct ProjDetailsDates: View {
    private let proj: Project
    
    init(_ proj: Project) {
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

//#Preview {
//    ProjDetailsDates()
//}
