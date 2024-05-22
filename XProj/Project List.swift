import SwiftUI

struct ProjectList: View {
    @Environment(ProjectListVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                ForEach(vm.filteredProjects) { project in
                    ProjectCard(project)
                }
            } header: {
                HStack {
                    Spacer()
                    
                    Text("\(vm.projects.count) Projects")
                }
            }
        }
        .searchable(text: $vm.searchPrompt)
        .searchSuggestions {
            SearchSuggestions()
        }
        .refreshableTask {
            vm.getFolders()
        }
    }
}

#Preview {
    ProjectList()
        .environment(ProjectListVM())
}
