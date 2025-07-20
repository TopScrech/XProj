import SwiftUI

struct NavContainer: View {
    @Environment(NavModel.self) private var nav
    
    @AppStorage("experience") private var experience: NavMode?
    
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
                NavModeButton()
                    .padding()
                    .onAppear {
                        nav.showExperiencePicker = true
                    }
            }
        }
        .sheet($nav.showExperiencePicker) {
            NavModePicker($experience)
        }
        .task {
            try? nav.load()
        }
        .onChange(of: nav.selectedCategory) {
            nav.save()
        }
        .onChange(of: nav.selectedProj) {
            nav.save()
        }
    }
}

#Preview {
    NavContainer()
        .environment(NavModel.shared)
}
