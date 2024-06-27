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
        
#if DEBUG
        MenuBarExtra("Project List", systemImage: "hammer") {
            MBProjectList()
                .environment(vm)
        }
#endif
    }
}
