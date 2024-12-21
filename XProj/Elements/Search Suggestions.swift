import SwiftUI

struct SearchSuggestions: View {
    @Environment(ProjListVM.self) private var vm
    
    private var suggestedProjects: [Proj] {
        guard !vm.searchPrompt.isEmpty else {
            return vm.lastOpenedProjects
        }
        
        return vm.lastOpenedProjects.filter {
            $0.name.contains(vm.searchPrompt)
        }
    }
    
    var body: some View {
        ForEach(suggestedProjects) { proj in
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
}

#Preview {
    SearchSuggestions()
        .environment(ProjListVM())
}
