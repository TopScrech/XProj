import SwiftUI

struct LayoutSettings: View {
    @EnvironmentObject private var store: ValueStorage
    
    var body: some View {
        Form {
            Section("Project details") {
                Toggle("Targets", isOn: $store.showProjTargets)
                
                Toggle("Target version", isOn: $store.showProjTargetVersion)
                    .disabled(!store.showProjTargets)
                    .foregroundStyle(store.showProjTargets ? .primary : .secondary)
                
                Toggle("Package dependencies", isOn: $store.showProjPackageDependencies)
                
                Toggle("App store link", isOn: $store.showProjAppStoreLink)
            }
            
            //            Section {
            //                Toggle("Bottom bar", isOn: $test)
            //
            //                Toggle("Vapor projects", isOn: $test)
            //
            //                Toggle("Derived Data", isOn: $test)
            //
            //                Toggle("List of all package dependencies", isOn: $test)
            //            }
        }
    }
}

#Preview {
    LayoutSettings()
        .environmentObject(ValueStorage())
}
