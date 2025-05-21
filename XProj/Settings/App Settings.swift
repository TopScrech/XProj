import ScrechKit
import LaunchAtLogin

struct AppSettings: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    @Environment(DerivedDataVM.self) private var ddvm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Form {
            Section("Selected folders") {
                Button {
                    vm.showPicker()
                } label: {
                    HStack {
                        Label("Projects", systemImage: "folder")
                        
                        Spacer()
                        
                        Text(vm.projectsFolder.isEmpty ? "Not selected" : vm.projectsFolder)
                            .secondary()
                            .lineLimit(1)
                    }
                }
                
                Button {
                    ddvm.showPicker()
                } label: {
                    HStack {
                        Label("Derived Data", systemImage: "folder")
                        
                        Spacer()
                        
                        Text(ddvm.derivedDataUrl?.description ?? "Not selected")
                            .secondary()
                            .lineLimit(1)
                    }
                }
            }
            
            Section {
                HStack {
                    Text("Navigation mode")
                    
                    Spacer()
                    
                    NavModeButton()
                }
                
                LaunchAtLogin.Toggle()
            }
            
            Section("Project details") {
                Toggle("Targets", isOn: $store.showProjTargets)
                
                Toggle("Target version", isOn: $store.showProjTargetVersion)
                    .disabled(!store.showProjTargets)
                    .foregroundStyle(store.showProjTargets ? .primary : .secondary)
                
                Toggle("Package dependencies", isOn: $store.showProjPackageDependencies)
                
                Toggle("App store link", isOn: $store.showProjAppStoreLink)
                
                Toggle("Git ignore", isOn: $store.showGitignore)
            }
            
            Section("Debug") {
                Button {
                    downloadExamples()
                } label: {
                    Label("Save example projects for testing", systemImage: "square.and.arrow.down")
                }
#if DEBUG
                Button("Clear navigation path") {
                    nav.clearNavCache()
                }
#endif
            }
        }
        .formStyle(.grouped)
        .buttonStyle(.plain)
        .scrollIndicators(.never)
        .frame(width: 500, height: 600)
    }
    
    private func downloadExamples() {
        guard let sourceUrl = Bundle.main.url(forResource: "Examples", withExtension: "zip") else {
            print("Examples.zip not found in the main bundle")
            return
        }
        
        guard let downloadsUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
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
