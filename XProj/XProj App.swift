import ScrechKit

@main
struct XProjApp: App {
    private var vm = ProjListVM()
    
    var body: some Scene {
        WindowGroup {
            Container()
                .environment(vm)
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
