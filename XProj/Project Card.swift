import SwiftUI

struct ProjectCard: View {
    private var vm = ProjectCardVM()
    
    private let project: Project
    
    init(_ project: Project) {
        self.project = project
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
                
                Text(project.path)
                    .footnote()
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            //            Text(project.attributes[.size] as? String ?? "")
            //                .footnote()
            //                .foregroundStyle(.secondary)
            
            let (found, filePath) = vm.findXcodeprojFile(project.path)
            
            Button {
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
