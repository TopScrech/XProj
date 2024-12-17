import ScrechKit

struct DerivedDataList: View {
    @State private var vm = DerivedDataVM()
    
    var body: some View {
        List {
            Button("Picker") {
                vm.openFolderPicker()
            }
            
            Section {
                HStack {
                    Text("Total:")
                    
                    Spacer()
                    
                    Text(formatBytes(vm.folders.map(\.size).reduce(Int64(0), +)))
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
