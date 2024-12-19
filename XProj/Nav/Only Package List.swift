import SwiftUI

struct OnlyPackageList: View {
    @Environment(ProjListVM.self) private var vm
    
    private var packages: [Project] {
        vm.filteredProjects.filter {
            $0.type == .package
        }
    }
    
    var body: some View {
        VStack {
            Text(vm.swiftToolsVersions)
            
            ProjList(packages)
        }
    }
}

#Preview {
    OnlyPackageList()
        .environment(ProjListVM())
}
