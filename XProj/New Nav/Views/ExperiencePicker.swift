// A navigation experience picker used to select the navigation architecture for the app

import SwiftUI

struct ExperiencePicker: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var experience: Experience?
    
    @State private var selection: Experience?
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Choose your navigation experience")
                    .largeTitle()
                    .bold()
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .padding()
                
                Spacer()
                
                LazyVGrid(columns: columns) {
                    ForEach(Experience.allCases) { experience in
                        ExperiencePickerItem(
                            selection: $selection,
                            experience: experience)
                    }
                }
                
                Spacer()
            }
            .scenePadding()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                ContinueButton {
                    continueAction()
                }
                .disabled(selection == nil)
            }
        }
        .frame(width: 600, height: 350)
        .interactiveDismissDisabled(selection == nil)
    }
    
    private var columns: [GridItem] {[
        GridItem(.adaptive(minimum: 250))
    ]}
    
    private func continueAction() {
        experience = selection
        dismiss()
    }
}

#Preview() {
    ExperiencePicker(experience: .constant(.stack))
}
