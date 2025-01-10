import SwiftUI

struct SidebarLink<Destination: View>: View {
    private let title: LocalizedStringKey
    private let icon: String
    private let color: Color
    private let destination: Destination
    
    init(_ title: LocalizedStringKey, icon: String, color: Color = .blue, destination: () -> Destination) {
        self.title = title
        self.icon = icon
        self.color = color
        self.destination = destination()
    }
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            Label {
                Text(title)
            } icon: {
                Image(systemName: icon)
                    .background(color, in: .rect(cornerRadius: 5))
            }
        }
        .buttonStyle(.plain)
    }
}
