import SwiftUI

struct ProjSwiftTools: View {
    private let version: String?
    
    init(_ version: String?) {
        self.version = version
    }
    
    var body: some View {
        if let version {
            HStack(spacing: 0) {
                Text("Swift tools: ")
                    .secondary()
                
                Text(version)
            }
            .padding(.vertical, 5)
        }
    }
}

#Preview {
    ProjSwiftTools("6.0")
        .darkSchemePreferred()
}
