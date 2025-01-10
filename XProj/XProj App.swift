import ScrechKit
import SettingsKit

@main
struct XProjApp: App {
    @StateObject private var store = ValueStorage()
    private var nav: NavModel = .shared
    private var dataModel: DataModel = .shared
    private var derivedData = DerivedDataVM()
    
    var body: some Scene {
        WindowGroup {
            NavContainer()
                .environment(nav)
                .environment(dataModel)
                .environment(derivedData)
                .environmentObject(store)
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            SidebarCommands()
        }
        .settings(design: .sidebar) {
            SettingsTab(.new(title: "General", image: Image(systemName: "gear")), id: "general") {
                SettingsSubtab(.noSelection, id: "no-selection") {
                    GeneralSettings()
                        .environment(nav)
                        .environment(dataModel)
                        .environment(derivedData)
                }
            }
            
            SettingsTab(.new(title: "Layout", image: Image(systemName: "paintbrush")), id: "layout", color: .yellow) {
                SettingsSubtab(.noSelection, id: "no-selection") {
                    LayoutSettings()
                        .environmentObject(store)
                }
            }
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
