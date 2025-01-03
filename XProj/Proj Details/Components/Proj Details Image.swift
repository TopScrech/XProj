import SwiftUI

struct ProjDetailsImage: View {
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    var body: some View {
        if let path = proj.projIcon(),
           let nsImage = NSImage(contentsOf: URL(fileURLWithPath: path)) {
            Image(nsImage: nsImage)
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(.rect(cornerRadius: 16))
                .onDrag {
                    let fileURL = URL(fileURLWithPath: path)
                    return NSItemProvider(object: fileURL as NSURL)
                }
        }
    }
}
