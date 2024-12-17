import SwiftUI

struct PublichesProjectsList: View {
    @Environment(ProjListVM.self) private var vm
    
    private var projects: [Project] {
        vm.filteredProjects.filter {
            for target in $0.targets {
                if let app = target.appStoreApp {
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
}
