import SwiftUI

struct ProjectList: View {
    @Environment(ProjectVM.self) private var vm
    
    @State private var searchPrompt = ""
    
    private var filteredProjects: [Project] {
        if searchPrompt.isEmpty {
            vm.projects
        } else {
            vm.projects.filter {
                $0.name.contains(searchPrompt)
            }
        }
    }
    
    private var lastOpenedProjects: [Project] {
        vm.projects.filter {
            $0.type == .proj
        }
        .prefix(5).sorted {
            $0.lastOpened > $1.lastOpened
        }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(filteredProjects) { project in
                    ProjectCard(project)
                }
            } header: {
                HStack {
                    Spacer()
                    
                    Text("\(vm.projects.count) Projects")
                }
            }
        }
        .searchable(text: $searchPrompt)
        .searchSuggestions {
            ForEach(lastOpenedProjects) { proj in
                Button {
                    searchPrompt = proj.name
                } label: {
                    HStack {
                        Text(proj.name)
                        
                        Spacer()
                        
                        Text(proj.lastOpened, format: .dateTime)
                    }
                }
            }
        }
        .refreshableTask {
            vm.getFolders()
        }
        .toolbar {
            Button("Read contents") {
                vm.getFolders()
            }
            .keyboardShortcut(.init("R"))
        }
    }
}

#Preview {
    ProjectList()
        .environment(ProjectVM())
}
