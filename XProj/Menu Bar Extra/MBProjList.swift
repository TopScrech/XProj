import ScrechKit
import OSLog

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
                            Logger().error("No project found")
                            return
                        }
                        
                        vm.openProj(proj)
                    }
                
                SFButton("document.on.clipboard", action: paste)
                    .buttonStyle(.plain)
            }
            .padding(.bottom, 5)
            
            ScrollView {
                LazyVStack {
                    ForEach(vm.filteredProjects.prefix(20)) {
                        MBProjCard($0)
                    }
                }
            }
            .onShortcut(1) {
                if let proj = vm.filteredProjects.first {
                    vm.openProj(proj)
                }
            }
            .onShortcut(2) {
                if vm.filteredProjects.count > 1 {
                    vm.openProj(vm.filteredProjects[1])
                }
            }
            .onShortcut(3) {
                if vm.filteredProjects.count > 2 {
                    vm.openProj(vm.filteredProjects[2])
                }
            }
            .onShortcut(4) {
                if vm.filteredProjects.count > 3 {
                    vm.openProj(vm.filteredProjects[3])
                }
            }
            .onShortcut(5) {
                if vm.filteredProjects.count > 4 {
                    vm.openProj(vm.filteredProjects[4])
                }
            }
            .onShortcut(6) {
                if vm.filteredProjects.count > 5 {
                    vm.openProj(vm.filteredProjects[5])
                }
            }
            .onShortcut(7) {
                if vm.filteredProjects.count > 6 {
                    vm.openProj(vm.filteredProjects[6])
                }
            }
            .onShortcut(8) {
                if vm.filteredProjects.count > 7 {
                    vm.openProj(vm.filteredProjects[7])
                }
            }
            .onShortcut(9) {
                if vm.filteredProjects.count > 8 {
                    vm.openProj(vm.filteredProjects[8])
                }
            }
        }
        .padding([.horizontal, .top])
        .scrollIndicators(.never)
        .task {
            focusState = true
        }
    }
    
    private func paste() {
        if let clipboard = NSPasteboard.general.string(forType: .string) {
            vm.searchPrompt = clipboard
        }
    }
}

#Preview {
    MBProjList()
        .darkSchemePreferred()
        .environment(DataModel.shared)
}
