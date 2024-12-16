import SwiftUI

struct PackageDepCard: View {
    private let package: PackageDependency
    
    init(_ package: PackageDependency) {
        self.package = package
    }
    
    var body: some View {
        NavigationLink {
            PackageDepDetails(package)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(package.package.name)
                        .headline()
                    
                    Spacer()
                    
                    Text(package.useCount)
                        .footnote()
                        .secondary()
                }
            }
            .padding(.vertical, 4)
        }
    }
}

//#Preview {
//    PackageDepCard()
//}
