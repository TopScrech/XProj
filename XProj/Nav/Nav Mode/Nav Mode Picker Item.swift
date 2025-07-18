import SwiftUI

struct NavModePickerItem: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var selection: NavMode?
    
    private var experience: NavMode
    
    init(_ selection: Binding<NavMode?>, for experience: NavMode) {
        _selection = selection
        self.experience = experience
    }
    
    var body: some View {
        Button {
            selection = experience
            dismiss()
        } label: {
            Label(selection: $selection, experience: experience)
        }
        .buttonStyle(.plain)
    }
}

private struct Label: View {
    @Binding var selection: NavMode?
    var experience: NavMode
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: experience.icon)
                .title()
                .foregroundStyle(shapeStyle(Color.accentColor))
            
            VStack(alignment: .leading) {
                Text(experience.name)
                    .bold()
                    .foregroundStyle(shapeStyle(.primary))
            }
        }
        .frame(width: 200, height: 50)
        .shadow(radius: selection == experience ? 4 : 0)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(selection == experience ?
                      AnyShapeStyle(Color.accentColor) :
                        AnyShapeStyle(.background))
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isHovering ? Color.accentColor : .clear)
        }
        .scaleEffect(isHovering ? 1.02 : 1)
        .onHover { isHovering in
            withAnimation {
                self.isHovering = isHovering
            }
        }
    }
    
    private func shapeStyle<S: ShapeStyle>(_ style: S) -> some ShapeStyle {
        if selection == experience {
            AnyShapeStyle(.background)
        } else {
            AnyShapeStyle(style)
        }
    }
}

#Preview {
    @Previewable @State
    var selection: NavMode?
    
    ForEach(NavMode.allCases) {
        NavModePickerItem(
            $selection,
            for: $0
        )
    }
}
