import SwiftUI

struct SearchSuggestions: View {
    @Environment(ProjectListVM.self) private var vm
    
    private var suggestedProjects: [Project] {
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
                    
                    Text(proj.lastOpened, format: .dateTime)
                }
            }
        }
    }
}

#Preview {
    SearchSuggestions()
        .environment(ProjectListVM())
}
