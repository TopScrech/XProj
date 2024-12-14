import ScrechKit

struct ProjectCard: View {
    @Environment(ProjectListVM.self) private var vm
    
    private let proj: Project
    private let projectsFolder: String
    
    init(_ proj: Project, projectsFolder: String = "") {
        self.proj = proj
        self.projectsFolder = projectsFolder
    }
    
    var body: some View {
        HStack {
            Image(systemName: proj.icon)
                .title()
                .foregroundStyle(proj.iconColor)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(proj.name)
                
                Text(proj.lastOpened, format: .dateTime)
                    .caption2()
                    .foregroundStyle(.secondary)
                
                Button {
                    openInFinder(rootedAt: proj.path)
                } label: {
                    let path = proj.path.replacingOccurrences(of: projectsFolder, with: "~")
                    
                    Text(path)
                        .footnote()
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            //            Text(proj.attributes[.size] as? String ?? "")
            //                .footnote()
            //                .foregroundStyle(.secondary)
            
            Button {
                vm.openProjects([proj.path])
            } label: {
                Image(systemName: "play")
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    List {
        ProjectCard(.init(
            name: "Preview",
            path: "/",
            type: .proj,
            lastOpened: Date(),
            attributes: [:]
        ))
        
        ProjectCard(.init(
            name: "Preview",
            path: "/",
            type: .package,
            lastOpened: Date(),
            attributes: [:]
        ))
    }
}
