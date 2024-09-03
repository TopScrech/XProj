import SwiftUI

struct MBProjectList: View {
    @Environment(ProjectListVM.self) private var vm
    
    @FocusState private var focusState
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            HStack {
                Text("\(vm.filteredProjects.count) Projects")
                
                let count = vm.findDuplicates().reduce(0) {
                    $0 + $1.count
                }
                
                Text("(\(count) duplicates)")
                    .foregroundStyle(.tertiary)
            }
            
            TextField("Search", text: $vm.searchPrompt)
                .focused($focusState)
                .textFieldStyle(.plain)
                .onSubmit {
                    guard let proj = vm.filteredProjects.first else {
                        print("No project found")
                        return
                    }
                    
#warning("Used twice")
                    
                    let (found, filePath) = vm.findXcodeprojFile(proj.path)
                    
                    if found, let filePath {
                        vm.launchProject(filePath)
                    } else {
                        vm.launchProject(proj.path + "/Package.swift")
                    }
                }
            
            ScrollView {
                ForEach(vm.filteredProjects) { proj in
                    MBProjectCard(proj)
                }
                .animation(.default, value: vm.filteredProjects)
            }
        }
        .padding()
        .scrollIndicators(.never)
        .task {
            focusState = true
        }
        .refreshableTask {
            vm.getFolders()
        }
    }
}

#Preview {
    MBProjectList()
}
