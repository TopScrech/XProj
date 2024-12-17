import ScrechKit

struct ProjDetails: View {
    @Environment(ProjListVM.self) private var vm
    
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text(proj.name)
                    .largeTitle()
                
                if let path = proj.projIcon(),
                   let nsImage = NSImage(contentsOf: URL(fileURLWithPath: path)) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(.rect(cornerRadius: 16))
                }
            }
            .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 0) {
                    Text("Last opened: ")
                        .secondary()
                    
                    Text(formattedDateAndTime(proj.openedAt))
                }
                
                if let modifiedAt = proj.modifiedAt {
                    HStack(spacing: 0) {
                        Text("Modified: ")
                            .secondary()
                        
                        Text(formattedDateAndTime(modifiedAt))
                    }
                }
                
                if let createdAt = proj.createdAt {
                    HStack(spacing: 0) {
                        Text("Created: ")
                            .secondary()
                        
                        Text(formattedDateAndTime(createdAt))
                    }
                }
            }
            .padding(.vertical, 5)
            
            if let version = proj.swiftToolsVersion {
                VStack {
                    Text("Swift tools: ")
                        .foregroundStyle(.secondary) +
                    
                    Text(version)
                }
                .padding(.vertical, 5)
            }
            
            HStack {
                Button("Xcode") {
                    vm.openProjects([proj.path])
                }
                
                Button("Finder") {
                    openInFinder(rootedAt: proj.path)
                }
            }
            .padding(.vertical, 5)
            
            if !proj.targets.isEmpty {
                Section {
                    ForEach(proj.targets) { target in
                        VStack(alignment: .leading) {
                            Text(target.name)
                                .title3()
                            
                            if let bundle = target.bundleId {
                                Text(bundle)
                                    .secondary()
                            }
                            
                            if let url = target.appStoreApp?.url {
                                Link("App Store", destination: url)
                            }
                        }
                    }
                } header: {
                    Text("Targets: \(proj.targets.count)")
                        .title2()
                }
            }
            
            if !proj.packages.isEmpty {
                Section {
                    ForEach(proj.packages) { package in
                        VStack(alignment: .leading) {
                            Text(package.name)
                            
                            if let author = package.author {
                                Text(author)
                                    .footnote()
                                    .secondary()
                            }
                            
                            if let requirement = package.requirementKind, let param = package.requirementParam {
                                Text("\(requirement): \(param)")
                                    .footnote()
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 2)
                        .contextMenu {
                            if let url = URL(string: package.repositoryURL) {
                                Link("Open in browser", destination: url)
                            }
                        }
                    }
                } header: {
                    Text("Package dependencies: \(proj.packages.count)")
                        .title2()
                }
            }
        }
    }
}

//#Preview {
//    ProjDetails()
//}
