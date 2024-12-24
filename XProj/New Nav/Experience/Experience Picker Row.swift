// A nav experience picker row that displays all experiences

import SwiftUI

struct ExperiencePickerItem: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var selection: Experience?
    
    private var experience: Experience
    
    init(_ selection: Binding<Experience?>, for experience: Experience) {
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
    @Binding var selection: Experience?
    var experience: Experience
    
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
    var selection: Experience?
    
    ForEach(Experience.allCases) {
        ExperiencePickerItem(
            $selection,
            for: $0
        )
    }
}
