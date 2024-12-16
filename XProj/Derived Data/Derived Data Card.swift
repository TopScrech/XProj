import SwiftUI

struct DerivedDataCard: View {
    private let folder: DerivedDataFolder
    
    init(_ folder: DerivedDataFolder) {
        self.folder = folder
    }
    
    var body: some View {
        HStack {
            Text(folder.name)
            
            Spacer()
            
            Text(folder.formattedSize)
                .secondary()
        }
    }
}

//#Preview {
//    DerivedDataCard()
//}
