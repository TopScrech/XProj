import SwiftUI

struct ProjectCard: View {
    private let project: Project
    
    init(_ project: Project) {
        self.project = project
    }
    
    var body: some View {
        HStack {
            Image(systemName: project.icon)
                .foregroundStyle(project.iconColor)
                .frame(width: 20)
            
            VStack(alignment: .leading) {
                Text(project.name)
                
                Text(project.type)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            Text(project.attributes[.size] as? String ?? "")
                .footnote()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    List {
        ProjectCard(.init(
            name: "",
            type: "",
            attributes: [:]
        ))
    }
}
