import SwiftUI

struct MBProjectList: View {
    @Environment(ProjectListVM.self) private var vm
    
    var body: some View {
        VStack {
            Text("\(vm.projects.count) Projects")
            
            ScrollView {
                ForEach(vm.projects) { proj in
                    MBProjectCard(proj)
                }
            }
            .refreshableTask {
                vm.getFolders()
            }
        }
    }
}

#Preview {
    MBProjectList()
}
