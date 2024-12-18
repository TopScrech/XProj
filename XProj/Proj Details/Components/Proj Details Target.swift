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
                let platforms = target.deploymentTargets.sorted(by: <)
                
                ForEach(platforms, id: \.key) { key, value in
                    HStack(spacing: 0) {
                        Image(systemName: icon(key))
                        
                        Text(value)
                            .footnote()
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }
}

//#Preview {
//    ProjDetailsTarget()
//}
