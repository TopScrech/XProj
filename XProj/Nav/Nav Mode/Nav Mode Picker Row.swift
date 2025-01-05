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
            Image(systemName: experience.imageName)
                .title()
                .foregroundStyle(shapeStyle(Color.accentColor))
            
            VStack(alignment: .leading) {
                Text(experience.localizedName)
                    .bold()
                    .foregroundStyle(shapeStyle(Color.primary))
                
                Text(experience.localizedDescription)
                    .callout()
                    .lineLimit(3, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(shapeStyle(Color.secondary))
            }
        }
        .shadow(radius: selection == experience ? 4 : 0)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(selection == experience ?
                      AnyShapeStyle(Color.accentColor) :
                        AnyShapeStyle(BackgroundStyle()))
            
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

#Preview() {
    @Previewable @State
    var selection: NavMode?
    
    ForEach(NavMode.allCases) {
        NavModePickerItem(
            $selection,
            for: $0
        )
    }
}
