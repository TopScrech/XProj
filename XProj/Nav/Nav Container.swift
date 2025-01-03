import SwiftUI

struct NavContainer: View {
    @Environment(NavModel.self) private var nav
    
    @AppStorage("experience") private var experience: Experience?
    
    var body: some View {
        @Bindable var nav = nav
        
        Group {
            switch experience {
            case .stack?:
                StackContainer()
                
            case .twoColumn?:
                TwoColumnContainer()
                
            case .threeColumn?:
                ThreeColumnContainer()
                
            case nil:
                ExperienceButton()
                    .padding()
                    .onAppear {
                        nav.showExperiencePicker = true
                    }
            }
        }
        .sheet($nav.showExperiencePicker) {
            ExperiencePicker($experience)
        }
        .task {
            try? nav.load()
        }
        .onChange(of: nav.selectedCategory) {
            save()
        }
        .onChange(of: nav.selectedProj) {
            save()
        }
    }
    
    private func save() {
        do {
            try nav.save()
        } catch {
            print(error)
        }
    }
}

#Preview {
    NavContainer()
        .environment(NavModel.shared)
}
