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
            }
            
            Button("Xcode") {
                vm.openProj(proj)
            }
            
            Button("Finder") {
                openInFinder(rootedAt: proj.path)
            }
        }
        .padding(.vertical, 5)
    }
}

//#Preview {
//    ProjDetailsActions(previewProj1)
//        .environment(DataModel.shared)
//}
