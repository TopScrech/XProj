import ScrechKit

struct ProjActions: View {
    @Environment(DataModel.self) private var vm
    @EnvironmentObject private var store: ValueStore
    @Environment(\.openURL) private var openURL
    
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    private var appStoreURL: URL? {
        proj.targets.filter {
            $0.appStoreApp != nil
        }
        .first?.appStoreApp?.url
    }
    
    var body: some View {
        HStack {
            if store.showProjAppStoreLink, let appStoreURL {
                Button("App Store") {
                    openURL(appStoreURL)
                }
                .help(appStoreURL)
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
                    openURL(url)
                }
                .frame(maxWidth: 100)
                .help(url)
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    ProjActions(PreviewProp.previewProj1)
        .darkSchemePreferred()
        .environment(DataModel.shared)
        .environmentObject(ValueStore())
}
