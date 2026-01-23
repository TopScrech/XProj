import SwiftUI

struct ProjDate: View {
    private let title: LocalizedStringKey
    private let date: Date?
    
    init(_ title: LocalizedStringKey, date: Date?) {
        self.title = title
        self.date = date
    }
    
    var body: some View {
        if let date {
            HStack(spacing: 0) {
                Text(title)
                    .secondary()
                
                Text(DateFormatters.formattedDateAndTime(date))
            }
        }
    }
}
