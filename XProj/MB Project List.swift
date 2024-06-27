import SwiftUI

struct MBProjectList: View {
    @Environment(ProjectListVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            Text("\(vm.filteredProjects.count) Projects")
            
            TextField("Search", text: $vm.searchPrompt)
            
            ScrollView {
                ForEach(vm.filteredProjects) { proj in
                    MBProjectCard(proj)
                }
            }
        }
        .padding()
        .scrollIndicators(.never)
        .refreshableTask {
            vm.getFolders()
        }
    }
}

#Preview {
    MBProjectList()
}
