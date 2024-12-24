import ScrechKit

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("Main Settings", systemImage: "gear") {
                MainSettings()
            }
        }
        .tint(.yellow)
    }
}

#Preview {
    SettingsView()
        .environment(DataModel.shared)
}
