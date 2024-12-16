import SwiftUI

struct PackageDepDetails: View {
    private let package: PackageDependency
    
    init(_ package: PackageDependency) {
        self.package = package
    }
    
    var body: some View {
        List {
            Section {
                Text(package.name)
                    .title()
            }
            
            ForEach(package.projects) { proj in
                Text(proj.name)
            }
        }
    }
}

//#Preview {
//    PackageDepDetails()
//}
