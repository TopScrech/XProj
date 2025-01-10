import ScrechKit
import LaunchAtLogin

struct GeneralSettings: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    @Environment(DerivedDataVM.self) private var ddvm
    
    var body: some View {
        Form {
            Section {
                VStack {
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
            } header: {
                Text("Selected folders")
                    .headline()
            }
            .buttonStyle(.plain)
            
            Section {
                HStack {
                    Text("Navigation mode")
                    
                    Spacer()
                    
                    NavModeButton()
                }
            }
            
            Section {
                LaunchAtLogin.Toggle()
            }
            
            Section {
                HStack {
                    Text("Save example projects for testing")
                    
                    Spacer()
                    
                    SFButton("square.and.arrow.down") {
                        downloadExamples()
                    }
                }
            }
#if DEBUG
            Section {
                HStack {
                    Text("Clear navigation path")
                    
                    Spacer()
                    
                    Button("Click") {
                        nav.clearNavCache()
                    }
                }
            } header: {
                Text("Debug")
                    .headline()
            }
#endif
        }
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
    GeneralSettings()
        .environment(NavModel.shared)
        .environment(DataModel.shared)
        .environment(DerivedDataVM())
}
