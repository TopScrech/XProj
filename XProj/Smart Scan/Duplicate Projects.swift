import ScrechKit

struct DuplicateProjects: View {
    @Environment(DataModel.self) private var vm
    
    private let duplicates: [[Proj]]
    
    init(_ duplicates: [[Proj]] = []) {
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
        .environment(DataModel())
}
