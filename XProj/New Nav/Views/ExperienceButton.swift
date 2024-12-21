// An button that presents the nav experience picker

import SwiftUI

struct ExperienceButton: View {
    @Environment(NavigationModel.self) private var navigationModel
    
    var body: some View {
        Button {
            navigationModel.showExperiencePicker = true
        } label: {
            Label("Experience", systemImage: "wand.and.stars")
                .help("Choose your navigation experience")
        }
    }
}

#Preview() {
    ExperienceButton()
        .environment(NavigationModel.shared)
}
