import ScrechKit

@main
struct XProjApp: App {
    private var vm = ProjectVM()
    
    var body: some Scene {
        WindowGroup {
            ProjectList()
                .environment(vm)
        }
        
        Settings {
            SettingsView()
                .environment(vm)
        }
    }
}
