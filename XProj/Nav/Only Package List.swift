import SwiftUI

struct OnlyPackageList: View {
    @Environment(ProjListVM.self) private var vm
    
    var body: some View {
        VStack {
            Text(vm.swiftToolsVersions)
            
            ProjList(vm.filteredProjects.filter {
                $0.type == .package
            })
        }
    }
}

#Preview {
    OnlyPackageList()
        .environment(ProjListVM())
}
