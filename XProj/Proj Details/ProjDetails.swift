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
            proj = sourceProj
            
            let needsDetails = sourceProj.targets.isEmpty
                && sourceProj.packages.isEmpty
                && sourceProj.platforms.isEmpty
            
            let needsAppStoreRefresh = sourceProj.targets.contains {
                $0.bundleId != nil && $0.appStoreApp == nil
            }
            
            if needsDetails {
                var updatedProj = sourceProj
                await updatedProj.loadDetails()
                proj = updatedProj
                return
            }
            
            if needsAppStoreRefresh {
                var updatedProj = sourceProj
                await updatedProj.loadTargets()
                proj = updatedProj
            }
        }
    }
}

#Preview {
    ProjDetails(PreviewProp.previewProj1)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
