import ScrechKit
import LaunchAtLogin

struct SettingsView: View {
    var body: some View {
        Group {
            if #available(macOS 15, *) {
                TabView {
                    Tab("Settings", systemImage: "gear") {
                        MainSettings()
                    }
                    
                    Tab("Other", systemImage: "hammer") {
                        LaunchAtLogin.Toggle()
                    }
                }
            } else {
                TabView {
                    MainSettings()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                    
                    LaunchAtLogin.Toggle()
                        .tabItem {
                            Label("Other", systemImage: "hammer")
                        }
                }
            }
        }
        .frame(width: 300, height: 300)
    }
}

#Preview {
    SettingsView()
        .environment(DataModel.shared)
}
