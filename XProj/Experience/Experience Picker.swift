// Nav experience picker used to select the nav architecture for the app

import SwiftUI

struct ExperiencePicker: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var experience: Experience?
    
    init(_ experience: Binding<Experience?>) {
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
                    ForEach(Experience.allCases) { experience in
                        ExperiencePickerItem($experience, for: experience)
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
    var experience: Experience? = .stack
    
    ExperiencePicker($experience)
}
