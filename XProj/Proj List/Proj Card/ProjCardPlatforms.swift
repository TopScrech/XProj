import SwiftUI

struct ProjCardPlatforms: View {
    private let proj: Proj
    private let showAppStoreIcon: Bool
    
    init(_ proj: Proj, showAppStoreIcon: Bool = true) {
        self.proj = proj
        self.showAppStoreIcon = showAppStoreIcon
    }
    
    var body: some View {
        ForEach(proj.platforms, id: \.self) {
            Image(systemName: Platform.icon($0))
        }
        
        if proj.hasWidgets {
            Image(systemName: "widget.large")
        }
        
        if proj.hasTests {
            Image(systemName: "testtube.2")
        }
        
        if proj.hasImessage {
            Image(systemName: "message.badge")
        }
        
        if proj.type == .vapor, proj.packages.contains(where: {
            $0.name == "webauthn-swift"
        }) {
            Image(systemName: "person.badge.key")
        }
        
        if showAppStoreIcon {
            if proj.targets.contains(where: {
                $0.appStoreApp?.url != nil
            }) {
                Image(.appStore)
                    .resizable()
                    .frame(16)
            }
        }
    }
}

#Preview {
    ProjCardPlatforms(PreviewProp.previewProj1)
        .darkSchemePreferred()
}
