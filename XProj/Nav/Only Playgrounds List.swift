import SwiftUI

struct OnlyPlaygroundsList: View {
    @Environment(ProjListVM.self) private var vm
    
    private var playgrounds: [Project] {
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
