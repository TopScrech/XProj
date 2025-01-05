// Nav mode picker

import SwiftUI

struct NavModePicker: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var experience: NavMode?
    
    init(_ experience: Binding<NavMode?>) {
        _experience = experience
    }
    
    private var columns: [GridItem] {[
        GridItem(.adaptive(minimum: 250))
    ]}
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Choose your navigation experience")
                        .bold()
                        .largeTitle()
                        .lineLimit(2, reservesSpace: true)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                    
                    Text("You might need to restart the app")
                        .secondary()
                }
                .padding()
                
                Spacer()
                
                LazyVGrid(columns: columns) {
                    ForEach(NavMode.allCases) { exp in
                        NavModePickerItem($experience, for: exp)
                    }
                }
                
                Spacer()
            }
            .scenePadding()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Dismiss") {
                    dismiss()
                }
            }
        }
        .frame(width: 600, height: 350)
        .interactiveDismissDisabled(experience == nil)
    }
}

#Preview() {
    @Previewable @State
    var experience: NavMode? = .stack
    
    NavModePicker($experience)
}
