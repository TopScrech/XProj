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
                let (found, filePath) = vm.findXcodeprojFile(proj.path)
                
                if found, let filePath {
                    vm.launchProj(filePath)
                } else {
                    vm.launchProj(proj.path + "/Package.swift")
                }
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
