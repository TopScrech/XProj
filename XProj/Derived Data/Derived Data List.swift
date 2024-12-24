import ScrechKit

struct DerivedDataList: View {
    @State private var vm = DerivedDataVM()
    
    var body: some View {
#warning("Show Derived Data of not existing projects")
        List {
            Button("Picker") {
                vm.showPicker()
            }
            
            if !vm.filteredFolders.isEmpty {
                Section {
                    HStack {
                        Text("Total:")
                        
                        Spacer()
                        
                        Text(vm.totalSize)
                            .numericTransition()
                            .monospacedDigit()
                            .animation(.default, value: vm.totalSize)
                    }
                    .bold()
                }
            }
            
            ForEach(vm.filteredFolders) { folder in
                DerivedDataCard(folder)
            }
        }
        .searchable(text: $vm.searchPrompt)
        .refreshableTask {
            DispatchQueue.global(qos: .background).async {
                vm.getFolders()
            }
        }
    }
}

#Preview {
    DerivedDataList()
}
