// An button that presents the nav experience picker

import SwiftUI

struct ExperienceButton: View {
    @Environment(NavModel.self) private var navModel
    
    var body: some View {
        Button {
            navModel.showExperiencePicker = true
        } label: {
            Label("Experience", systemImage: "wand.and.stars")
                .help("Choose your navigation experience")
        }
    }
}

#Preview() {
    ExperienceButton()
        .environment(NavModel.shared)
}
