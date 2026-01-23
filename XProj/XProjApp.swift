import ScrechKit

@main
struct XProjApp: App {
    @StateObject private var store = ValueStore()
    private var nav: NavModel = .shared
    private var vm: DataModel = .shared
    private var derivedData = DerivedDataVM()
    
    var body: some Scene {
        WindowGroup {
            NavContainer()
                .environment(nav)
                .environment(vm)
                .environment(derivedData)
                .environmentObject(store)
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            SidebarCommands()
        }
        
        WindowGroup(id: "code_lines", for: String.self) { $path in
            NavigationStack {
                CodeLineList($path)
            }
            .environmentObject(store)
        }
        
        Settings {
            AppSettings()
                .environment(nav)
                .environment(vm)
                .environment(derivedData)
                .environmentObject(store)
        }
        
        MenuBarExtra("Project List", systemImage: "hammer") {
            NavigationStack {
                MBProjList()
            }
            .environment(nav)
            .environment(vm)
            .environment(derivedData)
        }
        .menuBarExtraStyle(.window)
    }
}
