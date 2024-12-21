import ScrechKit

@main
struct XProjApp: App {
    @State private var vm = ProjListVM()
    
    private var nav: NavigationModel = .shared
    private var dataModel: DataModel = .shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(vm)
                .environment(nav)
                .environment(dataModel)
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            SidebarCommands()
        }
        
        Settings {
            SettingsView()
                .environment(vm)
                .environment(nav)
                .environment(dataModel)
        }
        
        MenuBarExtra("Project List", systemImage: "hammer") {
            NavigationStack {
                MBProjList()
            }
            .environment(vm)
            .environment(nav)
            .environment(dataModel)
        }
        .menuBarExtraStyle(.window)
    }
}
