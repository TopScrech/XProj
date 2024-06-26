import SwiftUI

struct MBProjectList: View {
    @Environment(ProjectListVM.self) private var vm
    
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
