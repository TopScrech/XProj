import ScrechKit

@main
struct XProjApp: App {
    private var vm = ProjectListVM()
    
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
                MBProjectList()
            }
            .environment(vm)
        }
        .menuBarExtraStyle(.window)
    }
}
