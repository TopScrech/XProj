import ScrechKit

struct DuplicateProjects: View {
    @Environment(ProjListVM.self) private var vm
    
    private let duplicates: [[Project]]
    
    init(_ duplicates: [[Project]] = []) {
        self.duplicates = duplicates
    }
    
    var body: some View {
        List(duplicates, id: \.self) { duplicates in
            DuplicateSection(duplicates)
        }
    }
}

#Preview {
    DuplicateProjects()
        .environment(ProjListVM())
}
