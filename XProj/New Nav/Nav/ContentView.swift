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
                StackContentView()
                
            case .twoColumn?:
                TwoColumnContentView()
                
            case .threeColumn?:
                ThreeColumnContentView()
                
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
        .sheet(isPresented: $nav.showExperiencePicker) {
            ExperiencePicker(experience: $experience)
        }
        .task {
            try? nav.load()
        }
        .onChange(of: scenePhase) { _, newScenePhase in
            if newScenePhase == .background {
                try? nav.save()
            }
        }
        .onChange(of: appearsActive) { _, appearsActive in
            if !appearsActive {
                try? nav.save()
            }
        }
    }
}

#Preview {
    ContentView()
}
