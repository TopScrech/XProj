import ScrechKit

@main
struct XProjApp: App {
    private var vm = ProjectVM()
    
    var body: some Scene {
        WindowGroup {
            Container()
                .environment(vm)
        }
        
        Settings {
            SettingsView()
                .environment(vm)
        }
    }
}
