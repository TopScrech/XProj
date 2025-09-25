import ScrechKit

struct MBProjCard: View {
    @Environment(DataModel.self) private var vm
    
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    var body: some View {
        HStack {
            Image(systemName: proj.icon)
                .foregroundStyle(proj.iconColor.gradient)
            
            Text(proj.name)
            
            Spacer()
            
            SFButton("play") {
                vm.openProj(proj)
            }
        }
    }
}

#Preview {
    MBProjCard(PreviewProp.previewProj1)
        .darkSchemePreferred()
        .environment(DataModel.shared)
}
