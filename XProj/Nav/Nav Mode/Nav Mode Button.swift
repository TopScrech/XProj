import SwiftUI

struct NavModeButton: View {
    @Environment(NavModel.self) private var navModel
    @EnvironmentObject private var store: ValueStore
    
    private var icon: String {
        store.navMode?.icon ?? "questionmark"
    }
    
    private var name: LocalizedStringKey {
        store.navMode?.name ?? ""
    }
    
    var body: some View {
        Button(name, systemImage: icon) {
            navModel.showNavModePicker = true
        }
        .help("Choose your navigation mode")
    }
}

#Preview {
    NavModeButton()
        .environment(NavModel.shared)
        .environmentObject(ValueStore())
}
