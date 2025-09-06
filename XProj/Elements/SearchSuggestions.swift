import SwiftUI

struct SearchSuggestions: View {
    @Environment(DataModel.self) private var vm
    
    private var suggestedProjects: [Proj] {
        guard !vm.searchPrompt.isEmpty else {
            return vm.lastOpenedProjects
        }
        
        return vm.lastOpenedProjects.filter {
            $0.name.contains(vm.searchPrompt)
        }
    }
    
    var body: some View {
        ForEach(suggestedProjects) {
            SearchSuggestion($0)
        }
    }
}

#Preview {
    SearchSuggestions()
        .environment(DataModel.shared)
}
