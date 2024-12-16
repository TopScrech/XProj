import SwiftUI

struct OnlyProjList: View {
    @Environment(ProjListVM.self) private var vm
    
    var body: some View {
        ProjList(vm.filteredProjects.filter {
            $0.type == .proj
        })
    }
}

#Preview {
    OnlyProjList()
}
