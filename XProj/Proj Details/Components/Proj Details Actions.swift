import ScrechKit

struct ProjDetailsActions: View {
    @Environment(ProjListVM.self) private var vm
    @Environment(\.openURL) private var openUrl
    
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        HStack {
            if let url = proj.targets.filter({ $0.appStoreApp != nil }).first?.appStoreApp?.url {
                Button("App Store") {
                    openUrl(url)
                }
            }
            
            Button("Xcode") {
                vm.openProjects([proj.path])
            }
            
            Button("Finder") {
                openInFinder(rootedAt: proj.path)
            }
        }
        .padding(.vertical, 5)
    }
}
