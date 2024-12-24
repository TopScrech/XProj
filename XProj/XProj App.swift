import ScrechKit

@main
struct XProjApp: App {
    private var nav: NavModel = .shared
    private var dataModel: DataModel = .shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(nav)
                .environment(dataModel)
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            SidebarCommands()
        }
        
        Settings {
            SettingsView()
                .environment(nav)
                .environment(dataModel)
        }
        
#warning("MenuBarExtra")
        //        MenuBarExtra("Project List", systemImage: "hammer") {
        //            NavigationStack {
        //                MBProjList()
        //            }
        //            .environment(nav)
        //            .environment(dataModel)
        //        }
        //        .menuBarExtraStyle(.window)
    }
}
