import SwiftUI

struct OnlyProjList: View {
    @Environment(ProjListVM.self) private var vm
    
    private var projects: [Project] {
        vm.filteredProjects.filter {
            $0.type == .proj
        }
    }
    
    var body: some View {
        ProjList(projects)
    }
}

#Preview {
    OnlyProjList()
        .environment(ProjListVM())
}
