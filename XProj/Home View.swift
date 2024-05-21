import SwiftUI

struct HomeView: View {
    private var vm = ProjectVM()
    
    @AppStorage("projects_folder_path") var projectsFolderPath = ""
    
    var body: some View {
        VStack {
            Button("Choose projects folder") {
                vm.openFolderPicker()
            }
            
            List {
                ForEach(vm.projects) { project in
                    HStack {
                        Image(systemName: project.icon)
                            .foregroundStyle(project.iconColor)
                        
                        VStack {
                            Text(project.name)
                            Text(project.typ)
                            
                            //                        Text(project.attributes[.size] as? String ?? "")
                            //                            .footnote()
                            //                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            Text("\(vm.projects.count) Projects")
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
    HomeView()
}
