import SwiftUI

struct OnlyPlaygroundsList: View {
    @Environment(ProjListVM.self) private var vm
    
    var body: some View {
        VStack {
            ProjList(vm.filteredProjects.filter {
                $0.type == .playground
            })
        }
    }
}

#Preview {
    OnlyPlaygroundsList()
        .environment(ProjListVM())
}
