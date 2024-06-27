import SwiftUI

struct MBProjectCard: View {
    private var vm = ProjectCardVM()
    
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        HStack {
            Image(systemName: proj.icon)
            
            Text(proj.name)
            
            Spacer()
            
            Button {
                let (found, filePath) = vm.findXcodeprojFile(proj.path)
                
                if found, let filePath {
                    vm.launchProject(filePath)
                } else {
                    vm.launchProject(proj.path + "/Package.swift")
                }
            } label: {
                Image(systemName: "play")
            }
        }
    }
}

#Preview {
    MBProjectCard(.init(
        name: "Preview",
        path: "/",
        type: .proj,
        lastOpened: Date(),
        attributes: [:]
    ))
}
