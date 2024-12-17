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
            
            ProjDetailsDates(proj)
            
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
                        ProjDetailsTarget(target)
                    }
                } header: {
                    Text("Targets: \(proj.targets.count)")
                        .title2()
                }
            }
            
            if !proj.packages.isEmpty {
                Section {
                    ForEach(proj.packages) { package in
                        ProjDetailsPackage(package)
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
