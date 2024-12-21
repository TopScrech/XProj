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
//            ProjDetails(proj)
        } label: {
            HStack {
                ProjCardImage(proj)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(proj.name)
                            .title3()
                        
                        ForEach(proj.platforms, id: \.self) { platform in
                            Image(systemName: icon(platform))
                        }
                        
                        if proj.type == .vapor, proj.packages.contains(where: {
                            $0.name == "webauthn-swift"
                        }) {
                            Image(systemName: "person.badge.key")
                        }
                    }
                    
                    let path = proj.path.replacingOccurrences(of: vm.projectsFolder, with: "~")
                    
                    Text(path)
                        .subheadline()
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                Text(formattedDate(proj.openedAt))
                    .secondary()
                
                //            Text(proj.attributes[.size] as? String ?? "")
                //                .footnote()
                //                .secondary()
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
                vm.openProj(proj)
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

#Preview {
    List {
        ProjCard(previewProj1)
        
        ProjCard(previewProj2)
    }
    .environment(ProjListVM())
}
