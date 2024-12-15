import ScrechKit

struct DuplicateProjCard: View {
    @Environment(ProjListVM.self) private var vm
    
    private let project: Project
    
    init(_ project: Project) {
        self.project = project
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Last opened: \(project.lastOpened, style: .date)")
            
            Button {
                openInFinder(rootedAt: project.path)
            } label: {
                let path = project.path.replacingOccurrences(of: vm.projectsFolder, with: "~")
                
                Text(path)
                    .footnote()
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

//#Preview {
//    DuplicateProjectCard()
//}
