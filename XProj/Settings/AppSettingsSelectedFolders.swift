import ScrechKit

struct AppSettingsSelectedFolders: View {
    @Environment(DataModel.self) private var vm
    @Environment(DerivedDataVM.self) private var ddvm
    
    var body: some View {
        Section("Selected folders") {
            Button {
                vm.showPicker()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Label("Projects", systemImage: "folder")
                        
                        Text(vm.projectsFolder.isEmpty ? "Not selected" : vm.projectsFolder)
                            .tertiary()
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if !vm.projectsFolder.isEmpty {
                        SFButton("xmark") {
                            vm.projectsFolder = ""
                            deleteBookmark("derived_data_bookmark")
                            vm.projects = []
                        }
                        .foregroundStyle(.red)
                    }
                }
                .animation(.default, value: vm.projectsFolder)
            }
            
            Button {
                ddvm.showPicker()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Label("Derived Data", systemImage: "folder")
                        
                        Text(ddvm.derivedDataUrl?.description ?? "Not selected")
                            .tertiary()
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if ddvm.derivedDataUrl?.description != nil {
                        SFButton("xmark") {
                            ddvm.derivedDataUrl = nil
                            deleteBookmark("derived_data_bookmark")
                            ddvm.folders = []
                        }
                        .foregroundStyle(.red)
                    }
                }
                .animation(.default, value: ddvm.derivedDataUrl)
            }
        }
    }
}

#Preview {
    AppSettingsSelectedFolders()
        .environment(DataModel())
        .environment(DerivedDataVM())
}
