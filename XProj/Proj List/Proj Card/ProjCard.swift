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
                    
                    ProjCardPlatforms(proj)
                }
                
                let path = proj.path.replacingOccurrences(of: vm.projectsFolder, with: "~")
                
                Text(path)
                    .subheadline()
                    .tertiary()
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
        .onDrag {
            let fileURL = URL(fileURLWithPath: proj.path)
            return NSItemProvider(object: fileURL as NSURL)
        }
        .contextMenu {
            if let url = proj.targets.filter({ $0.appStoreApp != nil }).first?.appStoreApp?.url {
                Section {
                    Button("App Store", systemImage: "apple.logo") {
                        openUrl(url)
                    }
                    .help(url)
                }
            }
            
            Button("Open in Xcode", systemImage: "hammer") {
                vm.openProj(proj)
            }
            .help(proj.path)
            
            Button("Open in Finder", systemImage: "finder") {
                openInFinder(rootedAt: proj.path)
            }
            .help(proj.path)
            
            Section {
                if let path = proj.fetchRemoteRepositoryURL(), let url = URL(string: path) {
                    Menu {
                        Button("Open") {
                            openUrl(url)
                        }
                        .help(url)
                        
                        ShareLink(item: url)
                            .help(url)
                    } label: {
                        Text("Remote")
                    }
                }
            }
        }
    }
}

#Preview {
    List {
        ProjCard(PreviewProp.previewProj1)
        ProjCard(PreviewProp.previewProj2)
    }
    .darkSchemePreferred()
    .environment(DataModel.shared)
}
