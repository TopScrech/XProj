import ScrechKit

struct ProjectCard: View {
    private var vm = ProjectCardVM()
    
    private let project: Project
    private let projectsFolder: String
    
    init(_ project: Project, projectsFolder: String = "") {
        self.project = project
        self.projectsFolder = projectsFolder
    }
    
    var body: some View {
        HStack {
            Image(systemName: project.icon)
                .title()
                .foregroundStyle(project.iconColor)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(project.name)
                
                Text(project.lastOpened, format: .dateTime)
                    .caption2()
                    .foregroundStyle(.secondary)
                
                Button {
                    openInFinder(rootedAt: project.path)
                } label: {
                    let path = project.path.replacingOccurrences(of: projectsFolder, with: "~")
                    
                    Text(path)
                        .footnote()
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            //            Text(project.attributes[.size] as? String ?? "")
            //                .footnote()
            //                .foregroundStyle(.secondary)
            
            Button {
                let (found, filePath) = vm.findXcodeprojFile(project.path)
                
                if found, let filePath {
                    vm.launchProject(filePath)
                } else {
                    vm.launchProject(project.path + "/Package.swift")
                }
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
