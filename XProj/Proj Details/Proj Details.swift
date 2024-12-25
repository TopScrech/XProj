import ScrechKit

struct ProjDetails: View {
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
            
            if let version = proj.swiftToolsVersion {
                VStack {
                    Text("Swift tools: ")
                        .foregroundStyle(.secondary) +
                    
                    Text(version)
                }
                .padding(.vertical, 5)
            }
            
            ProjDetailsActions(proj)
            
            ProjDetailsTargets(proj.targets)
            
            ProjDetailsDependencies(proj.packages)
        }
        .scrollIndicators(.never)
    }
}

//#Preview {
//    ProjDetails(previewProj1)
//        .environment(DataModel.shared)
//}
