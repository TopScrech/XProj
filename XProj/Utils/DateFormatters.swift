import Foundation

struct DateFormatters {
    static func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
            
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
            
        } else {
            let currentYear = calendar.component(.year, from: now)
            let dateYear = calendar.component(.year, from: date)
            
            if currentYear == dateYear {
                formatter.dateFormat = "MMM d"
            } else {
                formatter.dateFormat = "MMM d, yyyy"
            }
            
            return formatter.string(from: date)
        }
    }

    static func formattedDateAndTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        let now = Date()
        let timeString = timeFormatter.string(from: date)
        
        if calendar.isDateInToday(date) {
            return "Today at \(timeString)"
            
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday at \(timeString)"
            
        } else {
            let currentYear = calendar.component(.year, from: now)
            let dateYear = calendar.component(.year, from: date)
            
            if currentYear == dateYear {
                formatter.dateFormat = "MMM d"
            } else {
                formatter.dateFormat = "MMM d, yyyy"
            }
            
            return "\(formatter.string(from: date)) at \(timeString)"
        }
    }
}
