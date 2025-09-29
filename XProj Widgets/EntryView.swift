import SwiftUI

struct EntryView: View {
    private let entry: Provider.Entry
    
    init(_ entry: Provider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
            
            Text("Favorite Emoji:")
            Text(entry.configuration.favoriteEmoji)
        }
    }
}
