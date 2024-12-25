import SwiftUI

struct ExperienceToolbarViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ExperienceButton()
            }
    }
}

extension View {
    func experienceToolbar() -> some View {
        modifier(ExperienceToolbarViewModifier())
    }
}

#Preview() {
    NavigationStack {
        Color.white
            .experienceToolbar()
    }
}
