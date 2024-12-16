import SwiftUI

struct PackageDepCard: View {
    private let package: PackageDependency
    
    init(_ package: PackageDependency) {
        self.package = package
    }
    
    @State private var isHovered = false
    
    var body: some View {
        NavigationLink {
            PackageDepDetails(package)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(package.package.name)
                        .headline()
                    
                    Spacer()
                    
                    if isHovered, let url = URL(string: package.package.repositoryURL) {
                        Link(destination: url) {
                            Image(systemName: "link")
                                .frame(height: 15)
                        }
                    }
                    
                    Text(package.useCount)
                        .footnote()
                        .secondary()
                }
            }
            .padding(.vertical, 4)
        }
        .onHover { hover in
            isHovered = hover
        }
    }
}

//#Preview {
//    PackageDepCard()
//}
