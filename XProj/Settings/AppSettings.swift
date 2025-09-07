import SwiftUI
import LaunchAtLogin

struct AppSettings: View {
    @Environment(NavModel.self) private var nav
    
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
            
            AppSettingsSelectedFolders()
                        
            AppSettingsProjDetails()
            
            Section("Debug") {
                Button("Save example projects to Downloads folder", systemImage: "square.and.arrow.down") {
                    downloadExamples()
                }
#if DEBUG
                Button("Clear navigation path", systemImage: "xmark") {
                    nav.clearNavCache()
                }
                .foregroundStyle(.red)
#endif
            }
        }
        .formStyle(.grouped)
        .buttonStyle(.plain)
        .scrollIndicators(.never)
        .frame(width: 500, height: 600)
    }
    
    private func downloadExamples() {
        guard
            let sourceUrl = Bundle.main.url(forResource: "Examples", withExtension: "zip")
        else {
            print("Examples.zip not found")
            return
        }
        
        guard
            let downloadsUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        else {
            print("Downloads folder not located")
            return
        }
        
        let destinationUrl = downloadsUrl.appendingPathComponent("Examples.zip")
        
        do {
            try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
            print("Examples.zip successfully copied to the Downloads folder")
        } catch {
            print("Error copying Examples.zip:", error.localizedDescription)
        }
    }
}

#Preview {
    AppSettings()
        .environment(NavModel.shared)
        .environmentObject(ValueStore())
}
