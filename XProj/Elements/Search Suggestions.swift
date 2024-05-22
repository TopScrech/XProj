import SwiftUI

struct SearchSuggestions: View {
    @Environment(ProjectVM.self) private var vm
    
    var body: some View {
        ForEach(vm.lastOpenedProjects) { proj in
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
        .environment(ProjectVM())
}
