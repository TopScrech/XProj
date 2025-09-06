import SwiftUI

struct ProjSwiftTools: View {
    private let swiftToolsVersion: String?
    
    init(_ swiftToolsVersion: String?) {
        self.swiftToolsVersion = swiftToolsVersion
    }
    
    var body: some View {
        if let swiftToolsVersion {
            VStack {
                Text("Swift tools: ")
                    .foregroundStyle(.secondary) +
                
                Text(swiftToolsVersion)
            }
            .padding(.vertical, 5)
        }
    }
}

#Preview {
    ProjSwiftTools("6.0")
}
