import ScrechKit

struct ProjDetailsActions: View {
    @Environment(DataModel.self) private var vm
    @Environment(\.openURL) private var openUrl
    
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    var body: some View {
        HStack {
            if let url = proj.targets.filter({ $0.appStoreApp != nil }).first?.appStoreApp?.url {
                Button("App Store") {
                    openUrl(url)
                }
                .help(url.path)
            }
            
            Button("Xcode") {
                vm.openProj(proj)
            }
            .help(proj.path)
            
            Button("Finder") {
                openInFinder(rootedAt: proj.path)
            }
            .help(proj.path)
            
            if let path = proj.fetchRemoteRepositoryURL(), let url = URL(string: path) {
                Menu {
                    ShareLink(item: url)
                } label: {
                    Text("Remote")
                } primaryAction: {
                    openUrl(url)
                }
                .frame(maxWidth: 100)
                .help(url.path)
            }
        }
        .padding(.vertical, 5)
    }
}

//#Preview {
//    ProjDetailsActions(previewProj1)
//        .environment(DataModel.shared)
//}
