import SwiftUI

struct SmartScan: View {
    @Environment(ProjListVM.self) private var vm
    
    var body: some View {
        Text("Smart Scan")
        
        let duplicates = vm.findDuplicates()
        
        let count = duplicates.reduce(0) {
            $0 + $1.count
        }
        
        if count != 0 {
            NavigationLink {
                DuplicateProjects(duplicates)
            } label: {
                Text("\(count) duplicates")
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        } else {
            Text("✅")
        }
    }
}

#Preview {
    SmartScan()
        .environment(ProjListVM())
}
