import SwiftUI

struct SmartScan: View {
    @Environment(ProjListVM.self) private var vm
    
    var body: some View {
        HStack {
            let duplicates = vm.findDuplicates()
            
            let count = duplicates.reduce(0) {
                $0 + $1.count
            }
            
            Text("Smart Scan:")
            
            if count != 0 {
                NavigationLink {
                    DuplicateProjects(duplicates)
                } label: {
                    Text("\(count) duplicates")
                        .underline()
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            } else {
                Text("✅")
            }
        }
    }
}

#Preview {
    SmartScan()
        .environment(ProjListVM())
}
