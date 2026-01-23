import SwiftUI

struct ProjDependencyList: View {
    private let packages: [Package]
    
    init(_ packages: [Package]) {
        self.packages = packages
    }
    
    var body: some View {
        if !packages.isEmpty {
            Section {
                ForEach(packages) {
                    ProjDependencyCard($0)
                }
            } header: {
                Text("Package dependencies: \(packages.count)")
                    .title2()
            }
        }
    }
}

#Preview {
    ProjDependencyList([])
        .darkSchemePreferred()
}
