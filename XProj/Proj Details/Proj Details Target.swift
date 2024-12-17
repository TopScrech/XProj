import SwiftUI

struct ProjDetailsTarget: View {
    private let target: Target
    
    init(_ target: Target) {
        self.target = target
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(target.name)
                        .title3()
                    
                    ForEach(target.deploymentTargets.sorted(by: <), id: \.key) { key, value in
                        Text("\(key) \(value)")
                            .footnote()
                            .foregroundStyle(.tertiary)
                    }
                }
                
                if let bundle = target.bundleId {
                    Text(bundle)
                        .secondary()
                }
            }
            
            Spacer()
            
            if let url = target.appStoreApp?.url {
                Link("App Store", destination: url)
            }
        }
    }
}
