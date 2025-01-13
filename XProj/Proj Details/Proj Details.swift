import ScrechKit

struct ProjDetails: View {
    @Environment(NavModel.self) private var vm
    @EnvironmentObject private var store: ValueStorage
    
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    var body: some View {
        List {
            Button("Debug") {
                print(proj)
            }
            
            VStack(alignment: .leading) {
                Text(proj.name)
                    .largeTitle()
                
                ProjDetailsImage(proj)
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
            
            ProjDetailsActions(proj)
            
            if store.showProjTargets {
                ProjDetailsTargets(proj.targets)
            }
            
            if store.showProjPackageDependencies {
                ProjDetailsDependencies(proj.packages)
            }
        }
        .scrollIndicators(.never)
    }
}

//#Preview {
//    ProjDetails(previewProj1)
//        .environment(NavModel.shared)
//        .environment(DataModel.shared)
//        .environmentObject(ValueStorage())
//}
