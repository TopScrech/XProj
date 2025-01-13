import ScrechKit

struct ProjDetailsActions: View {
    @Environment(DataModel.self) private var vm
    @EnvironmentObject private var store: ValueStorage
    @Environment(\.openURL) private var openUrl
    
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    private var appStoreUrl: URL? {
        proj.targets.filter {
            $0.appStoreApp != nil
        }
        .first?.appStoreApp?.url
    }
    
    var body: some View {
        HStack {
            if store.showProjAppStoreLink, let appStoreUrl {
                Button("App Store") {
                    openUrl(appStoreUrl)
                }
                .help(appStoreUrl)
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
                .help(url)
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    ProjDetailsActions(previewProj1)
        .environment(DataModel.shared)
        .environmentObject(ValueStorage())
}
