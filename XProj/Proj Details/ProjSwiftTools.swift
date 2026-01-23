import SwiftUI

struct ProjSwiftTools: View {
    private let swiftToolsVersion: String?
    
    init(_ swiftToolsVersion: String?) {
        self.swiftToolsVersion = swiftToolsVersion
    }
    
    var body: some View {
        if let swiftToolsVersion {
            HStack(spacing: 0) {
                Text("Swift tools: ")
                    .secondary()
                
                Text(swiftToolsVersion)
            }
            .padding(.vertical, 5)
        }
    }
}

#Preview {
    ProjSwiftTools("6.0")
        .darkSchemePreferred()
}
