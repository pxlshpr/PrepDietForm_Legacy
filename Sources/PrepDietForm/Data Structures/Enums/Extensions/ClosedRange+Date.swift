import Foundation

extension ClosedRange<Date> {
    var description: String {
        "\(lowerBound.calendarDayString) to \(upperBound.calendarDayString)"
    }
    
    var days: [Date] {
        var days: [Date] = []
        let calendar = Calendar(identifier: .gregorian)
        calendar.enumerateDates(
            startingAfter: lowerBound,
            matching: DateComponents(hour: 0, minute: 0, second:0),
            matchingPolicy: .nextTime)
        { (date, _, stop) in
            guard let date = date, date <= upperBound else {
                stop = true
                return
            }
            days.append(date)
        }
        return days
    }
}
