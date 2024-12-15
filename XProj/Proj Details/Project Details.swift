import SwiftUI

struct ProjectDetails: View {
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        Text(proj.name)
    }
}

//#Preview {
//    ProjectDetails()
//}
