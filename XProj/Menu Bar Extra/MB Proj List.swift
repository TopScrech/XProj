import SwiftUI

struct MBProjList: View {
    @Environment(DataModel.self) private var vm
    
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
                    
                    vm.openProj(proj)
                }
            
            ScrollView {
                ForEach(vm.filteredProjects) { proj in
                    MBProjCard(proj)
                }
                .animation(.default, value: vm.filteredProjects)
            }
        }
        .padding()
        .scrollIndicators(.never)
        .task {
            focusState = true
        }
//        .refreshableTask {
//            vm.getFolders()
//        }
    }
}

#Preview {
    MBProjList()
        .environment(ProjListVM())
}
