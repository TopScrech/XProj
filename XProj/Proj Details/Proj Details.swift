import SwiftUI

struct ProjDetails: View {
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    @State private var packages: [Package] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(proj.name)
            
            if let path = proj.projIcon(),
               let nsImage = NSImage(contentsOf: URL(fileURLWithPath: path)) {
                Image(nsImage: nsImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 16))
            }
            
            ForEach(packages) { package in
                VStack(alignment: .leading) {
                    Text(package.name)
                    
                    Text(package.repositoryURL)
                    
                    Text("\(package.requirementKind): \(package.requirementParam)")
                        .footnote()
                        .secondary()
                }
                .padding(.vertical, 2)
            }
            
            Button("Packages") {
                loadPackages()
            }
        }
    }
    
    private func loadPackages() {
        do {
            let packages = try proj.parseSwiftPackages(proj.path)
            self.packages = packages
        } catch {
            print("Whoops")
        }
    }
}

//#Preview {
//    ProjDetails()
//}
