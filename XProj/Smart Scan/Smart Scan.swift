import SwiftUI

struct SmartScan: View {
    @Environment(DataModel.self) private var vm
    
    var body: some View {
        Text("Smart Scan")
            .secondary()
        
        let duplicates = vm.findDuplicates()
        
        let count = duplicates.reduce(0) {
            $0 + $1.count
        }
        
        if count != 0 {
            NavigationLink("\(count) duplicates") {
                DuplicateProjects(duplicates)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.yellow)
        }
    }
}

#Preview {
    SmartScan()
        .environment(ProjListVM())
}
