import ScrechKit

struct ProjCard: View {
    @Environment(NavModel.self) private var navModel
    @Environment(DataModel.self) private var vm
    @Environment(\.openURL) private var openURL
    
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
                    
                    ProjCardPlatforms(proj, showAppStoreIcon: showAppStoreIcon)
                }
                
                let path = proj.path.replacing(vm.projectsFolder, with: "~")
                
                Text(path)
                    .subheadline()
                    .tertiary()
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(DateFormatters.formattedDate(proj.openedAt))
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
            let selectedProjects = navModel.selectedProj.contains(proj)
            ? navModel.selectedProj
            : Set([proj])
            let canRemoveFavorites = selectedProjects.allSatisfy(vm.isFavorite)
            
            Button(
                canRemoveFavorites ? "Remove Favorite" : "Add Favorite",
                systemImage: canRemoveFavorites ? "star.slash" : "star"
            ) {
                if canRemoveFavorites {
                    vm.removeFavorites(selectedProjects)
                } else {
                    vm.addFavorites(selectedProjects)
                }
            }
            
            if let url = proj.targets.filter({ $0.appStoreApp != nil }).first?.appStoreApp?.url {
                Section {
                    Button("App Store", systemImage: "apple.logo") {
                        openURL(url)
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
                            openURL(url)
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
    
    private var showAppStoreIcon: Bool {
        navModel.selectedCategory != .appStore
    }
}

#Preview {
    List {
        ProjCard(PreviewProp.previewProj1)
        ProjCard(PreviewProp.previewProj2)
    }
    .darkSchemePreferred()
    .environment(NavModel(selectedCategory: .proj))
    .environment(DataModel.shared)
}
