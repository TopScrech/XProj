// A recipe tile, displaying the recipe's photo and name

import SwiftUI

struct ProjGridItem: View {
    private var proj: Proj
    
    init(_ recipe: Proj) {
        self.proj = recipe
    }
    
    @State private var isHovering = false
    
    var body: some View {
        VStack {
            ProjCardImage(proj)
                .frame(maxWidth: 240, maxHeight: 240)
            
            Text(proj.name)
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

#Preview() {
    ProjGridItem(.mock)
}
