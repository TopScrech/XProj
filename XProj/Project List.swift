import SwiftUI

struct ProjectList: View {
    @Environment(ProjectListVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                ForEach(vm.filteredProjects) { project in
                    ProjectCard(project, projectsFolder: vm.projectsFolder)
                }
            } header: {
                HStack {
                    Text("\(vm.projects.count) Projects")
                    
                    Spacer()
                    
                    let duplicates = vm.findDuplicates()
                    let count = duplicates.reduce(0) {
                        $0 + $1.count
                    }
                    
                    Text("Smart Scan:")
                    
                    if count != 0 {
                        NavigationLink {
                            DuplicateProjects(duplicates)
                        } label: {
                            Text("\(count) duplicates")
                                .underline()
                                .foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("✅")
                    }
                }
            }
        }
        .searchable(text: $vm.searchPrompt)
        .onSubmit {
            print("test")
        }
        .searchSuggestions {
            SearchSuggestions()
        }
        .refreshableTask {
            vm.getFolders()
            
            //            let duplicates: [()] = vm.findDuplicates().map { duplicates in
            //                print(duplicates.map(\.name))
            //            }
        }
        .toolbar {
            ToolbarItemGroup {
                ProjectListToolbar()
            }
        }
    }
}

#Preview {
    ProjectList()
        .environment(ProjectListVM())
}
