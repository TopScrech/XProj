import ScrechKit

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("Settings", systemImage: "gear") {
                MainSettings()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(DataModel.shared)
}
