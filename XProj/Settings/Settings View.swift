import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            ScrollView {
                VStack(alignment: .leading) {
                    SidebarLink("General", icon: "gear") {
                        GeneralSettings()
                    }
                }
            }
        } detail: {
            Text("Select a group")
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    SettingsView()
}
