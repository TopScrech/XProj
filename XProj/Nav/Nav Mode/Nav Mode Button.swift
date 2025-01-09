// An button that presents the nav mode picker

import SwiftUI

struct NavModeButton: View {
    @Environment(NavModel.self) private var navModel
    
    var body: some View {
        Button("Navigation mode") {
            navModel.showExperiencePicker = true
        }
        .help("Choose your navigation mode")
    }
}

#Preview() {
    NavModeButton()
        .environment(NavModel.shared)
}
