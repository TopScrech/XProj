import SwiftUI

struct NavModeButton: View {
    @Environment(NavModel.self) private var navModel
    
    @AppStorage("experience") private var experience: NavMode?
    
    private var icon: String {
        experience?.icon ?? "questionmark"
    }
    
    private var name: LocalizedStringKey {
        experience?.name ?? ""
    }
    
    var body: some View {
        Button(name, systemImage: icon) {
            navModel.showExperiencePicker = true
        }
        .help("Choose your navigation mode")
    }
}

#Preview {
    NavModeButton()
        .environment(NavModel.shared)
}
