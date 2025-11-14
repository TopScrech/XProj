import SwiftUI

struct SearchSuggestion: View {
    @Environment(DataModel.self) private var vm
    
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    var body: some View {
        Button {
            vm.searchPrompt = proj.name
        } label: {
            HStack {
                Text(proj.name)
                
                Spacer()
                
                Text(proj.openedAt, format: .dateTime)
            }
        }
    }
}

#Preview {
    SearchSuggestion(.mock)
        .darkSchemePreferred()
        .environment(DataModel.shared)
}
