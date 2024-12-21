import SwiftUI

struct DuplicateSection: View {
    private let duplicates: [Proj]
    
    init(_ duplicates: [Proj]) {
        self.duplicates = duplicates
    }
    
    var body: some View {
        Section(duplicates.first?.name ?? "Unknown") {
            ForEach(duplicates) { proj in
                ProjCard(proj)
            }
        }
    }
}

#Preview {
    DuplicateSection([])
}
