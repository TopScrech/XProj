import SwiftUI

struct NavContainer: View {
    @Environment(NavModel.self) private var nav
    @Environment(DataModel.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var nav = nav
        
        Group {
            switch store.navMode {
            case .twoColumn?:
                TwoColumnContainer()
                
            case .threeColumn?:
                ThreeColumnContainer()
                
            case nil:
                NavModeButton()
                    .padding()
                    .onAppear {
                        nav.showNavModePicker = true
                    }
            }
        }
        .sheet($nav.showNavModePicker) {
            NavModePicker($store.navMode)
        }
        .task {
            try? nav.load()
        }
        .task(id: vm.projectsFolder) {
            guard !vm.projectsFolder.isEmpty else {
                return
            }
            
            await vm.loadAppStoreProjectsIfNeeded()
            await vm.loadPlatformProjectsIfNeeded()
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
        .darkSchemePreferred()
        .environment(NavModel.shared)
        .environmentObject(ValueStore())
}
