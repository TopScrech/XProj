import SwiftUI

struct MBProjCard: View {
    @Environment(ProjListVM.self) private var vm
    
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        HStack {
            Image(systemName: proj.icon)
                .foregroundStyle(proj.iconColor.gradient)
            
            Text(proj.name)
            
            Spacer()
            
            Button {
                vm.openProj(proj)
            } label: {
                Image(systemName: "play")
            }
        }
    }
}

#Preview {
    MBProjCard(previewProj1)
        .environment(ProjListVM())
}
