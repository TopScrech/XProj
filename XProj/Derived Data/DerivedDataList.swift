import ScrechKit

struct DerivedDataList: View {
    @Environment(DerivedDataVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
#warning("Show Derived Data of not existing projects")
        List {
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
            }
#warning("searchable crashes cause there's already a searchbar")
        }
        .environment(vm)
        //        .searchable(text: $vm.searchPrompt)
        .toolbar {
            Button("Change folder", action: vm.showPicker)
            Button("Clear", action: vm.deleteAllFiles)
        }
    }
}

#Preview {
    DerivedDataList()
        .darkSchemePreferred()
        .environment(DerivedDataVM())
}
