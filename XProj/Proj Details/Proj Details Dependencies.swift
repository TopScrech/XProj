import SwiftUI

struct ProjDetailsDependencies: View {
    private let packages: [Package]
    
    init(_ packages: [Package]) {
        self.packages = packages
    }
    
    var body: some View {
        if !packages.isEmpty {
            Section {
                ForEach(packages) { package in
                    ProjDetailsPackage(package)
                }
            } header: {
                Text("Package dependencies: \(packages.count)")
                    .title2()
            }
        } else {
#if DEBUG
            Text("No packages found")
#endif
        }
    }
}

//#Preview {
//    ProjDetailsDependencies()
//}
