import ScrechKit

struct MainSettings: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        ScrollView {
            GroupBox {
                Button("Change projects folder") {
                    vm.showPicker()
                }
                
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
        guard let sourceURL = Bundle.main.url(forResource: "Examples", withExtension: "zip") else {
            print("Examples.zip not found in the main bundle")
            return
        }
        
        guard let downloadsUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            print("Unable to locate the Downloads folder")
            return
        }
        
        let destinationUrl = downloadsUrl.appendingPathComponent("Examples.zip")
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationUrl)
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
}
