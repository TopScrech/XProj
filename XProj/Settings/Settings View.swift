import ScrechKit

struct SettingsView: View {
    @Environment(ProjectListVM.self) private var vm
    
    var body: some View {
        VStack {
            Button("Choose projects folder") {
                vm.openFolderPicker()
            }
            
            Button("Examples") {
                downloadExamples()
            }
            
#if DEBUG
            Button("Cause a fatal error") {
                fatalError("Crash button pressed.")
            }
            
            Button("Exit") {
                exit(0)
            }
            
            Button("Crash") {
                let url = URL(string: "")!
            }
#endif
        }
        .frame(width: 200, height: 300)
    }
    
    private func downloadExamples() {
        guard let sourceURL = Bundle.main.url(forResource: "Examples", withExtension: "zip") else {
            print("Examples.zip not found in the main bundle.")
            return
        }
        
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            print("Unable to locate the Downloads folder.")
            return
        }
        
        let destinationURL = downloadsURL.appendingPathComponent("Examples.zip")
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            print("Examples.zip successfully downloaded to the Downloads folder.")
        } catch {
            print("Error downloading Examples.zip: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
        .environment(ProjectListVM())
}
