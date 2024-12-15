import SwiftUI

struct ProjDetails: View {
    private let proj: Project
    
    init(_ proj: Project) {
        self.proj = proj
    }
    
    var body: some View {
        VStack {
            Text(proj.name)
            
            if let path = proj.projIcon(),
               let nsImage = NSImage(contentsOf: URL(fileURLWithPath: path)) {
                Image(nsImage: nsImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 16))
            }
                        
            Button("Packages") {
                do {
                    let packages = try proj.parseSwiftPackages(proj.path)
                    
                    for package in packages {
                        print("Package Name: \(package.name)")
                        print("Repository URL: \(package.repositoryURL)")
                        print("Requirement Kind: \(package.requirementKind)")
                        print("Requirement Parameter: \(package.requirementParam)")
                        print("---------------------------")
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}

//#Preview {
//    ProjDetails()
//}
