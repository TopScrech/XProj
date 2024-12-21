import SwiftUI

struct PublichesProjectsList: View {
    @Environment(ProjListVM.self) private var vm
    
    private var projects: [Proj] {
        vm.filteredProjects.filter {
            for target in $0.targets {
                if target.appStoreApp != nil {
                    return true
                }
            }
            
            return false
        }
    }
    
    var body: some View {
        NavigationLink {
            ProjList(projects)
        } label: {
            Label("App Store", systemImage: "app.badge.checkmark")
        }
        .disabled(projects.isEmpty)
    }
}

#Preview {
    PublichesProjectsList()
        .environment(ProjListVM())
}
