import SwiftUI

struct ContentView: View {
    @Environment(\.appearsActive) private var appearsActive
    @Environment(\.scenePhase) private var scenePhase
    
    private var nav: NavigationModel = .shared
    private var dataModel: DataModel = .shared
    
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
                VStack {
                    Text("🧑🏼‍🍳 Bon appétit!")
                        .largeTitle()
                    
                    ExperienceButton()
                }
                .padding()
                .onAppear {
                    nav.showExperiencePicker = true
                }
            }
        }
        .environment(nav)
        .environment(dataModel)
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
        .onChange(of: nav.selectedRecipe) { _, newExperience in
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
