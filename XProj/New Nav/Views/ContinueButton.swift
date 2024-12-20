// Confirmation button

import SwiftUI

struct ContinueButton: View {
    var action: () -> Void
    
    var body: some View {
        Button("Continue", action: action)
            .buttonStyle(.borderedProminent)
    }
}

#Preview() {
    ContinueButton {}
}
