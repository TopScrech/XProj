import SwiftUI

struct AppSettingsProjDetails: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Project details") {
            Toggle(isOn: $store.showProjTargets) {
                Label("Targets", systemImage: "macbook.and.iphone")
            }
            
            if store.showProjTargets {
                Toggle(isOn: $store.showProjTargetVersion) {
                    Label("Target version", systemImage: "info")
                }
            }
            
            Toggle(isOn: $store.showProjPackageDependencies) {
                Label("Package dependencies", systemImage: "shippingbox")
            }
            
            Toggle(isOn: $store.showProjAppStoreLink) {
                Label("App Store link", systemImage: "link")
            }
            
            Toggle(isOn: $store.showGitignore) {
                Label("Git ignore", systemImage: "app.connected.to.app.below.fill")
            }
            
            Toggle(isOn: $store.showProjCodeLines) {
                Label("Code line count", systemImage: "list.number")
            }
            
            if store.showProjCodeLines {
                TextField("File extensions for counting", text: $store.codeLineCountingExtensions)
            }
        }
        .animation(.default, value: store.showProjTargets)
    }
}

#Preview {
    AppSettingsProjDetails()
        .environmentObject(ValueStore())
}
