import ScrechKit

struct ProjCard: View {
    @Environment(ProjListVM.self) private var vm
    @Environment(\.openURL) private var openUrl
    
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        NavigationLink {
            ProjDetails(proj)
        } label: {
            HStack {
                ProjCardImage(proj)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(proj.name)
                        
                        ForEach(proj.platforms, id: \.self) { platform in
                            Image(systemName: icon(platform))
                                .footnote()
                        }
                    }
                    
                    let path = proj.path.replacingOccurrences(of: vm.projectsFolder, with: "~")
                    
                    Text(path)
                        .footnote()
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                Text(formattedDate(proj.openedAt))
                    .secondary()
                
                //            Text(proj.attributes[.size] as? String ?? "")
                //                .footnote()
                //                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 5)
        }
        .contextMenu {
            if let url = proj.targets.filter({ $0.appStoreApp != nil }).first?.appStoreApp?.url {
                Section {
                    Button("App Store") {
                        openUrl(url)
                    }
                }
            }
            
            Button {
                vm.openProjects([proj.path])
            } label: {
                Text("Open in Xcode")
            }
            
            Button {
                openInFinder(rootedAt: proj.path)
            } label: {
                Text("Open in Finder")
            }
        }
    }
}

//#Preview {
//    List {
//        ProjCard(.init(
//            name: "Preview",
//            path: "/",
//            type: .proj,
//            lastOpened: Date(),
//            attributes: [:]
//        ))
//
//        ProjCard(.init(
//            name: "Preview",
//            path: "/",
//            type: .package,
//            lastOpened: Date(),
//            attributes: [:]
//        ))
//    }
//}
