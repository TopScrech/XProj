import ScrechKit

struct MainSettings: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    @Environment(DerivedDataVM.self) private var ddvm
    
    var body: some View {
        List {
            Section("Selected folders") {
                Button {
                    vm.showPicker()
                } label: {
                    HStack {
                        Text("Projects")
                        
                        Spacer()
                        
                        Text(vm.projectsFolder)
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
            .buttonStyle(.plain)
            
            GroupBox {
                Button("Example projects") {
                    downloadExamples()
                }
                
                NavModeButton()
            }
#if DEBUG
            Button("Clear nav") {
                nav.clearNavCache()
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
    SettingsView()
        .environment(NavModel.shared)
        .environment(DataModel.shared)
        .environment(DerivedDataVM())
}
