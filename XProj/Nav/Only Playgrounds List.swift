import SwiftUI

struct OnlyPlaygroundsList: View {
    @Environment(ProjListVM.self) private var vm
    
    private var playgrounds: [Proj] {
        vm.filteredProjects.filter {
            $0.type == .playground
        }
    }
    
    var body: some View {
        VStack {
            ProjList(playgrounds)
        }
    }
}

#Preview {
    OnlyPlaygroundsList()
        .environment(ProjListVM())
}
