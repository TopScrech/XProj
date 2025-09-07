import SwiftUI

struct ProjTargets: View {
    private let targets: [Target]
    
    init(_ targets: [Target]) {
        self.targets = targets
    }
    
    var body: some View {
        if !targets.isEmpty {
            Section {
                ForEach(targets) {
                    ProjTarget($0)
                }
            } header: {
                Text("Targets: \(targets.count)")
                    .title2()
            }
        }
    }
}

#Preview {
    ProjTargets([])
}
