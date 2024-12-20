import ScrechKit

@main
struct XProjApp: App {
    @State private var vm = ProjListVM()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(vm)
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            SidebarCommands()
        }
        
        Settings {
            SettingsView()
                .environment(vm)
        }
        
        MenuBarExtra("Project List", systemImage: "hammer") {
            NavigationStack {
                MBProjList()
            }
            .environment(vm)
        }
        .menuBarExtraStyle(.window)
    }
}
