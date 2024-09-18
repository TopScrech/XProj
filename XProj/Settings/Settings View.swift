import ScrechKit

struct SettingsView: View {
    @Environment(ProjectListVM.self) private var vm
    
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
        .environment(ProjectListVM())
}
