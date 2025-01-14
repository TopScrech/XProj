import SwiftUI

struct NavModeButton: View {
    @Environment(NavModel.self) private var navModel
    
    @AppStorage("experience") private var experience: NavMode?
    
    private var icon: String {
        experience?.imageName ?? "questionmark"
    }
    
    private var name: LocalizedStringKey {
        experience?.localizedName ?? ""
    }
    
    var body: some View {
        Button {
            navModel.showExperiencePicker = true
        } label: {
            Label(name, systemImage: icon)
        }
        .help("Choose your navigation mode")
    }
}

#Preview {
    NavModeButton()
        .environment(NavModel.shared)
}
