import SwiftUI

struct DerivedDataCard: View {
    @Environment(DerivedDataVM.self) private var vm
    
    private let folder: DerivedDataFolder
    
    init(_ folder: DerivedDataFolder) {
        self.folder = folder
    }
    
    var body: some View {
        HStack {
            Text(folder.formattedName)
            
            Spacer()
            
            Text(folder.formattedSize)
                .secondary()
            
            Button(role: .destructive) {
                vm.deleteFile(folder.name)
            } label: {
                Image(systemName: "trash")
                    .footnote()
            }
            .buttonStyle(.plain)
            .help("Delete")
        }
        .contextMenu {
            Button("Delete", systemImage: "trash", role: .destructive) {
                vm.deleteFile(folder.name)
            }
        }
    }
}

#Preview {
    DerivedDataCard(.init(name: "Preview", size: 64))
        .darkSchemePreferred()
        .environment(DerivedDataVM())
}
