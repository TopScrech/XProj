import ScrechKit

struct AppSettingsSelectedFolders: View {
    @Environment(DataModel.self) private var vm
    @Environment(DerivedDataVM.self) private var ddvm
    
    var body: some View {
        Section("Selected folders") {
            Button(action: vm.showPicker) {
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
                            BookmarkManager.deleteBookmark("derived_data_bookmark")
                            vm.projects = []
                        }
                        .foregroundStyle(.red)
                    }
                }
                .animation(.default, value: vm.projectsFolder)
            }
            
            Button(action: ddvm.showPicker) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Label("Derived Data", systemImage: "folder")
                        
                        Text(ddvm.derivedDataURL?.description ?? "Not selected")
                            .tertiary()
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if ddvm.derivedDataURL?.description != nil {
                        SFButton("xmark") {
                            ddvm.derivedDataURL = nil
                            BookmarkManager.deleteBookmark("derived_data_bookmark")
                            ddvm.folders = []
                        }
                        .foregroundStyle(.red)
                    }
                }
                .animation(.default, value: ddvm.derivedDataURL)
            }
        }
    }
}

#Preview {
    AppSettingsSelectedFolders()
        .darkSchemePreferred()
        .environment(DataModel())
        .environment(DerivedDataVM())
}
