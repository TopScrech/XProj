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
                
                ProjDetailsImage(proj)
            }
            .padding(.bottom, 10)
            
            ProjDetailsDates(proj)
            
            ProjDetailsSwiftTools(proj.swiftToolsVersion)
            
            ProjDetailsActions(proj)
            
            if store.showProjTargets {
                ProjDetailsTargets(proj.targets)
            }
            
            if store.showProjPackageDependencies {
                ProjDetailsDependencyList(proj.packages)
            }
            
            
            if store.showGitignore {
                ProjDetailsGitignore(proj.path)
            }
        }
        .scrollIndicators(.never)
    }
}

#Preview {
    ProjDetails(previewProj1)
        .environmentObject(ValueStore())
}
