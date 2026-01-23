import ScrechKit

struct ProjDetails: View {
    @EnvironmentObject private var store: ValueStore
    
    private let sourceProj: Proj
    @State private var proj: Proj
    
    init(_ proj: Proj) {
        sourceProj = proj
        _proj = State(initialValue: proj)
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text(proj.name)
                    .largeTitle()
                
                ProjImage(proj)
            }
            .padding(.bottom, 10)
            
            ProjDates(proj)
            
            ProjSwiftTools(proj.swiftToolsVersion)
            
            ProjActions(proj)
            
            if store.showProjCodeLines {
                ProjCodeLines(proj)
            }
            
            if store.showProjTargets {
                ProjTargets(proj.targets)
            }
            
            if store.showProjPackageDependencies {
                ProjDependencyList(proj.packages)
            }
            
            if store.showGitignore {
                ProjGitignore(proj.path)
            }
        }
        .scrollIndicators(.never)
        .onChange(of: sourceProj.id) { _, _ in
            proj = sourceProj
        }
        .task(id: sourceProj.id) {
            if sourceProj.targets.isEmpty && sourceProj.packages.isEmpty && sourceProj.platforms.isEmpty {
                var updatedProj = sourceProj
                await updatedProj.loadDetails()
                proj = updatedProj
            } else {
                proj = sourceProj
            }
        }
    }
}

#Preview {
    ProjDetails(PreviewProp.previewProj1)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
