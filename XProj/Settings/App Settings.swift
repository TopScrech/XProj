import ScrechKit
import LaunchAtLogin

struct AppSettings: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    @Environment(DerivedDataVM.self) private var ddvm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Navigation mode")
                    
                    Spacer()
                    
                    NavModeButton()
                }
                
                LaunchAtLogin.Toggle()
            }
            
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
            
            Section("Project details") {
                Toggle(isOn: $store.showProjTargets) {
                    Label("Targets", systemImage: "macbook.and.iphone")
                }
                
                if store.showProjTargets {
                    Toggle(isOn: $store.showProjTargetVersion) {
                        Label("Target version", systemImage: "info")
                    }
                }
                
                Toggle(isOn: $store.showProjPackageDependencies) {
                    Label("Package dependencies", systemImage: "shippingbox")
                }
                
                Toggle(isOn: $store.showProjAppStoreLink) {
                    Label("App store link", systemImage: "link")
                }
                
                Toggle(isOn: $store.showGitignore) {
                    Label("Git ignore", systemImage: "app.connected.to.app.below.fill")
                }
            }
            
            Section("Debug") {
                Button {
                    downloadExamples()
                } label: {
                    Label("Save example projects to Downloads folder", systemImage: "square.and.arrow.down")
                }
#if DEBUG
                Button {
                    nav.clearNavCache()
                } label: {
                    Label("Clear navigation path", systemImage: "xmark")
                        .foregroundStyle(.red)
                }
#endif
            }
        }
        .formStyle(.grouped)
        .buttonStyle(.plain)
        .scrollIndicators(.never)
        .frame(width: 500, height: 600)
        .animation(.default, value: store.showProjTargets)
    }
    
    private func downloadExamples() {
        guard
            let sourceUrl = Bundle.main.url(forResource: "Examples", withExtension: "zip")
        else {
            print("Examples.zip not found in the main bundle")
            return
        }
        
        guard
            let downloadsUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        else {
            print("Unable to locate the Downloads folder")
            return
        }
        
        let destinationUrl = downloadsUrl.appendingPathComponent("Examples.zip")
        
        do {
            try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
            print("Examples.zip successfully downloaded to the Downloads folder")
        } catch {
            print("Error downloading Examples.zip:", error.localizedDescription)
        }
    }
}

#Preview {
    AppSettings()
        .environment(NavModel.shared)
        .environment(DataModel.shared)
        .environment(DerivedDataVM())
        .environmentObject(ValueStore())
}
