import ScrechKit

struct SettingsView: View {
    var body: some View {
        if #available(macOS 15, *) {
            TabView {
                Tab("Settings", systemImage: "gear") {
                    MainSettings()
                }
            }
        } else {
            TabView {
                MainSettings()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(DataModel.shared)
}
