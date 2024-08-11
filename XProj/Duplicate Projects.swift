import ScrechKit

struct DuplicateProjects: View {
    @Environment(ProjectListVM.self) private var vm
    
    private let duplicates: [[Project]]
    
    init(_ duplicates: [[Project]] = []) {
        self.duplicates = duplicates
    }
    
    var body: some View {
        List {
            ForEach(duplicates, id: \.self) { duplicate in
                Section(duplicate.first?.name ?? "Unknown") {
                    ForEach(duplicate, id: \.self) { project in
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
            }
        }
    }
}

#Preview {
    DuplicateProjects()
        .environment(ProjectListVM())
}
