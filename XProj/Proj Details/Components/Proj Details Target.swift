import SwiftUI

struct ProjDetailsTarget: View {
    private let target: Target
    
    init(_ target: Target) {
        self.target = target
    }
    
    var body: some View {
        HStack {
            if let url = target.appStoreApp?.url {
                Link(destination: url) {
                    Image(.appStore)
                        .resizable()
                        .frame(width: 32, height: 32)
                }
            }
            
            VStack(alignment: .leading) {
                Text(target.name)
                    .title3()
                
                if let bundle = target.bundleId {
                    Text(bundle)
                        .secondary()
                }
            }
            
            Spacer()
            
            HStack {
                ForEach(target.deploymentTargets, id: \.self) { platform in
                    HStack(spacing: 0) {
                        Image(systemName: icon(platform))
                        
                        Text(platform.split(separator: " ").last ?? "")
                            .footnote()
                            .foregroundStyle(.tertiary)
                    }
                    
                    if target.type == .iMessage {
                        Image(systemName: "widget.large")
                    }
                    
                    if target.type == .unitTests || target.type == .uiTests {
                        Image(systemName: "message.badge")
                    }
                }
            }
        }
    }
}

//#Preview {
//    ProjDetailsTarget()
//}
