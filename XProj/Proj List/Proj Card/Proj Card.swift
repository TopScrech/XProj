import ScrechKit

struct ProjCard: View {
    @Environment(DataModel.self) private var vm
    @Environment(\.openURL) private var openUrl
    
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    var body: some View {
        HStack {
            ProjCardImage(proj)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(proj.name)
                        .title3()
                        .lineLimit(2)
                    
                    ForEach(proj.platforms, id: \.self) { platform in
                        Image(systemName: icon(platform))
                    }
                    
                    if proj.type == .vapor, proj.packages.contains(where: {
                        $0.name == "webauthn-swift"
                    }) {
                        Image(systemName: "person.badge.key")
                    }
                }
                
                #warning("projectsFolder")
                let path = proj.path.replacingOccurrences(of: vm.projectsFolder, with: "~")
                
                Text(path)
                    .subheadline()
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(formattedDate(proj.openedAt))
                .secondary()
            
            //            Text(proj.attributes[.size] as? String ?? "")
            //                .footnote()
            //                .secondary()
        }
        .padding(.vertical, 5)
        .contextMenu {
            if let url = proj.targets.filter({ $0.appStoreApp != nil }).first?.appStoreApp?.url {
                Section {
                    Button("App Store") {
                        openUrl(url)
                    }
                }
            }
            
            Button("Open in Xcode") {
                vm.openProj(proj)
            }
            
            Button("Open in Finder") {
                openInFinder(rootedAt: proj.path)
            }
        }
    }
}

#Preview {
    List {
        ProjCard(previewProj1)
        
        ProjCard(previewProj2)
    }
    .environment(DataModel())
}
