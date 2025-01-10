import ScrechKit
import LaunchAtLogin

struct SettingsView: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    @Environment(DerivedDataVM.self) private var ddvm
    
    @State private var lalEnabled = LaunchAtLogin.isEnabled
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GroupBox {
                    VStack(spacing: 5) {
                        Button {
                            vm.showPicker()
                        } label: {
                            HStack {
                                Text("Projects")
                                
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
                                Text("Derived Data")
                                
                                Spacer()
                                
                                Text(ddvm.derivedDataUrl?.description ?? "Not selected")
                                    .secondary()
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(5)
                } label: {
                    Text("Selected folders")
                        .headline()
                }
                .buttonStyle(.plain)
                
                GroupBox {
                    HStack {
                        Text("Navigation mode")
                        
                        Spacer()
                        
                        NavModeButton()
                    }
                    .padding(5)
                }
                
                GroupBox {
                    Toggle(isOn: $lalEnabled) {
                        HStack {
                            Text("Launch at login")
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .toggleStyle(.switch)
                    .padding(5)
                    .onChange(of: lalEnabled) { _, newValue in
                        LaunchAtLogin.isEnabled = newValue
                    }
                }
                
                GroupBox {
                    HStack {
                        Text("Save example projects for testing")
                        
                        Spacer()
                        
                        SFButton("square.and.arrow.down") {
                            downloadExamples()
                        }
                    }
                    .padding(5)
                }
#if DEBUG
                GroupBox {
                    HStack {
                        Text("Clear navigation path")
                        
                        Spacer()
                        
                        Button("Click") {
                            nav.clearNavCache()
                        }
                    }
                    .padding(5)
                } label: {
                    Text("Debug")
                        .headline()
                }
#endif
            }
        }
        .frame(width: 400)
        .padding()
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
            print("Error downloading Examples.zip: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
        .environment(NavModel.shared)
        .environment(DataModel.shared)
        .environment(DerivedDataVM())
}
