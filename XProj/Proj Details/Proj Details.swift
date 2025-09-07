import ScrechKit

struct ProjDetails: View {
    @EnvironmentObject private var store: ValueStore
    
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
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
    }
}

#Preview {
    ProjDetails(previewProj1)
        .environmentObject(ValueStore())
}
