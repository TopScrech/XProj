import ScrechKit

struct MBProjList: View {
    @Environment(DataModel.self) private var vm
    
    @FocusState private var focusState
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            HStack {
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
                
                SFButton("document.on.clipboard") {
                    if let clipboard = NSPasteboard.general.string(forType: .string) {
                        vm.searchPrompt = clipboard
                    }
                }
            }
            
            ScrollView {
                ForEach(vm.filteredProjects) { proj in
                    MBProjCard(proj)
                }
            }
        }
        .padding()
        .scrollIndicators(.never)
        .task {
            focusState = true
        }
    }
}

#Preview {
    MBProjList()
        .environment(DataModel.shared)
}
