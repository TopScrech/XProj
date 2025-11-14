import SwiftUI

struct ProjGridItem: View {
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    @State private var isHovering = false
    
    var body: some View {
        VStack {
            ProjCardImage(proj)
                .frame(maxWidth: 240, maxHeight: 240)
            
            Text(proj.name)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
        }
        .tint(.primary)
        .scaleEffect(CGSize(width: scale, height: scale))
        .onHover {
            isHovering = $0
        }
    }
    
    private var scale: CGFloat {
        isHovering ? 1.05 : 1
    }
}

#Preview {
    ProjGridItem(.mock)
        .darkSchemePreferred()
}
