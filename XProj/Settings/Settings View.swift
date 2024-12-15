import ScrechKit

struct SettingsView: View {
    @Environment(ProjListVM.self) private var vm
    
    var body: some View {
        TabView {
            Tab("Main Settings", systemImage: "gear") {
                MainSettings()
            }
#if DEBUG
            Tab("Debug", systemImage: "house.fill") {
                ImageDropView()
            }
#endif
        }
        .tint(.yellow)
    }
}

#Preview {
    SettingsView()
        .environment(ProjListVM())
}
