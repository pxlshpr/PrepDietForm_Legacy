import Foundation

extension Date {
    var tdeeFormat: String {
        let dayString: String
        var timeString = shortTime
        if Calendar.current.isDateInToday(self) { dayString = "Today" }
        else if Calendar.current.isDateInYesterday(self) { dayString = "Yesterday" }
        else if Calendar.current.isDateInTomorrow(self) { dayString = "Tomorrow" }
        else {
            let formatter = DateFormatter()
            let sameYear = year == Date().year
            formatter.dateFormat = sameYear ? "d MMM" : "d MMM yy"
            dayString = formatter.string(from: self)
            timeString = ""
        }
        if timeString.isEmpty {
            return dayString
        } else {
            return dayString + ", " + timeString
        }
    }
}
