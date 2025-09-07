import SwiftUI

struct ProjTarget: View {
    @EnvironmentObject private var store: ValueStore
    
    private let target: Target
    
    init(_ target: Target) {
        self.target = target
    }
    
    var body: some View {
        HStack {
            if store.showProjAppStoreLink, let url = target.appStoreApp?.url {
                Link(destination: url) {
                    Image(.appStore)
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                .help(url)
            }
            
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text(target.name)
                        .title3()
                        .lineLimit(2)
                    
                    if store.showProjTargetVersion, target.type != .unitTests && target.type != .uiTests {
                        if let version = target.version, let build = target.build {
                            Text(" v\(version) (\(build))")
                                .secondary()
                        }
                    }
                }
                
                if let bundle = target.bundleId {
                    Text(bundle)
                        .tertiary()
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            HStack {
                ForEach(target.deploymentTargets, id: \.self) { platform in
                    HStack(spacing: 0) {
                        Image(systemName: icon(platform))
                        
                        Text(platform.split(separator: " ").last ?? "")
                            .footnote()
                            .tertiary()
                    }
                }
                
                if target.type == .widgets {
                    Image(systemName: "widget.large")
                }
                
                if target.type == .unitTests || target.type == .uiTests {
                    Image(systemName: "testtube.2")
                }
                
                if target.type == .iMessage {
                    Image(systemName: "message.badge")
                }
            }
        }
        .contextMenu {
            if let url = target.appStoreApp?.url {
                Link("App Store", destination: url)
                    .help(url)
                
                ShareLink(item: url)
                    .help(url)
            }
        }
    }
}

#Preview {
    ProjTarget(
        Target(
            id: "id",
            name: "Preview",
            bundleId: "dev.topscrech.XProj",
            type: .app,
            deploymentTargets: ["iOS 17.0"],
            appStoreApp: nil,
            version: "4.16",
            build: "0"
        )
    )
    .padding()
    .environmentObject(ValueStore())
}
