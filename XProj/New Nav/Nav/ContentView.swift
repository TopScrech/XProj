import SwiftUI

struct ContentView: View {
    @Environment(NavigationModel.self) private var nav
    @Environment(DataModel.self) private var dataModel
    
    @Environment(\.appearsActive) private var appearsActive
    @Environment(\.scenePhase) private var scenePhase
    
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
        .onChange(of: nav.selectedCategory) { _, newExperience in
            do {
                try nav.save()
            } catch {
                print(error)
            }
        }
        .onChange(of: nav.selectedProj) { _, newExperience in
            do {
                try nav.save()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    ContentView()
}
