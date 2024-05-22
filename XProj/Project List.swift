import SwiftUI

struct ProjectList: View {
    @Environment(ProjectVM.self) private var vm
    
    var body: some View {
        List {
            Section {
                ForEach(vm.projects) { project in
                    ProjectCard(project)
                }
            } header: {
                HStack {
                    Spacer()
                    
                    Text("\(vm.projects.count) Projects")
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
