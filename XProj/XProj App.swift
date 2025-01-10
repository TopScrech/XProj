import ScrechKit

@main
struct XProjApp: App {
    private var nav: NavModel = .shared
    private var dataModel: DataModel = .shared
    private var derivedData = DerivedDataVM()
    
    var body: some Scene {
        WindowGroup {
            NavContainer()
                .environment(nav)
                .environment(dataModel)
                .environment(derivedData)
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            SidebarCommands()
        }
        
        Settings {
            SettingsView()
                .environment(nav)
                .environment(dataModel)
                .environment(derivedData)
        }
        
        MenuBarExtra("Project List", systemImage: "hammer") {
            NavigationStack {
                MBProjList()
            }
            .environment(nav)
            .environment(dataModel)
            .environment(derivedData)
        }
        .menuBarExtraStyle(.window)
    }
}
