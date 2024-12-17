import SwiftUI

struct ProjDetailsTargets: View {
    private let targets: [Target]
    
    init(_ targets: [Target]) {
        self.targets = targets
    }
    
    var body: some View {
        if !targets.isEmpty {
            Section {
                ForEach(targets) { target in
                    ProjDetailsTarget(target)
                }
            } header: {
                Text("Targets: \(targets.count)")
                    .title2()
            }
        } else {
#if DEBUG
            Text("No targets found")
#endif
        }
    }
}

//#Preview {
//    ProjDetailsTargets()
//}
