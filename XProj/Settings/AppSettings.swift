import SwiftUI
import LaunchAtLogin

struct AppSettings: View {
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
            
            AppSettingsDebug()
        }
        .formStyle(.grouped)
        .buttonStyle(.plain)
        .scrollIndicators(.never)
        .frame(width: 500, height: 600)
    }    
}

#Preview {
    AppSettings()
        .environment(NavModel.shared)
        .environmentObject(ValueStore())
}
