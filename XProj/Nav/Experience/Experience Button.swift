// An button that presents the nav mode picker

import SwiftUI

struct ExperienceButton: View {
    @Environment(NavModel.self) private var navModel
    
    var body: some View {
        Button("Navigation mode") {
            navModel.showExperiencePicker = true
        }
        .help("Choose your navigation mdoe")
    }
}

#Preview() {
    ExperienceButton()
        .environment(NavModel.shared)
}
