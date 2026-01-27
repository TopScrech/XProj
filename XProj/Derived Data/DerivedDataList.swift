import ScrechKit

struct DerivedDataList: View {
    @Environment(DerivedDataVM.self) private var vm
    @State private var selection: Set<DerivedDataFolder.ID> = []
    
    var body: some View {
        @Bindable var vm = vm
        
        List(selection: $selection) {
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
            
            ForEach(vm.filteredFolders) {
                DerivedDataCard($0)
                    .tag($0.id)
            }
#warning("searchable crashes cause there's already a searchbar")
        }
        .environment(vm)
        .onDeleteCommand(perform: deleteSelected)
        //        .searchable(text: $vm.searchPrompt)
        .toolbar {
            Button("Change folder", action: vm.showPicker)
            Button("Clear", action: vm.deleteAllFiles)
        }
    }
    
    private func deleteSelected() {
        guard !selection.isEmpty else {
            return
        }
        
        let selectedNames = selection
        selection.removeAll()
        
        selectedNames.forEach(vm.deleteFile)
    }
}

#Preview {
    DerivedDataList()
        .darkSchemePreferred()
        .environment(DerivedDataVM())
}
