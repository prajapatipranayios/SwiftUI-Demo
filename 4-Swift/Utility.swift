//
//  Utility.swift
//

import UIKit

typealias AlertHandler = (Int) -> ()

enum DateFormat: String {
    case apiDateTime = "yyyy-MM-dd HH:mm:ss"
    case apiDateTimeWithAmPm = "yyyy-MM-dd HH:mm:ssa"
    case apiDateOnly = "yyyy-MM-dd"
    case displayDate = "dd MMM, yyyy"
    case displayDateDash = "dd-MM-yyyy"
    case displayDateWithSpace = "dd MMM yyyy"
    case time24 = "HH:mm:ss"
    case time24Short = "HH:mm"
    case time12 = "hh:mm a"
    case fullDay = "EEEE"
    case fullDate = "MM d, yyyy"
}

class Utility {
    
    // MARK: - JSON Conversion
    class func json(from object: Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Generic Date Formatting
    class func formatDate(_ dateString: String, input: DateFormat, output: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = input.rawValue
        guard let date = formatter.date(from: dateString) else { return "" }
        formatter.dateFormat = output.rawValue
        return formatter.string(from: date)
    }
    
    // MARK: - Backward Compatibility (Old Method Names)
    class func convertDateFormater(_ date: String) -> String {
        return formatDate(date, input: .apiDateTime, output: .displayDate)
    }
    
    class func convertDateFormaterSubscriptionDetail(_ date: String) -> String {
        return formatDate(date, input: .apiDateTimeWithAmPm, output: .displayDateDash)
    }
    
    class func converOnlytDateFormater(_ date: String) -> String {
        return formatDate(date, input: .apiDateOnly, output: .displayDate)
    }
    
    class func converOnlytDateFormater2(_ date: String) -> String {
        return formatDate(date, input: .apiDateOnly, output: .displayDateDash)
    }
    
    class func converOnlytDateFormater3(_ date: String) -> String {
        return formatDate(date, input: .displayDateDash, output: .apiDateOnly)
    }
    
    class func converOnlytDateFormater4(_ date: String) -> String {
        return formatDate(date, input: .apiDateOnly, output: .displayDateWithSpace)
    }
    
    class func converTimeFormater(_ time: String) -> String {
        return formatDate(time, input: .time24, output: .time24Short)
    }
    
    // MARK: - Subscription Expiry
    class func checkSubscriptionExpired(expiredDate: String) -> Int {
        let today = Date().toString(format: .displayDateDash)
        let exDate = formatDate(expiredDate, input: .apiDateTimeWithAmPm, output: .displayDateDash)
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.displayDateDash.rawValue
        guard let eDate = formatter.date(from: exDate),
              let tDate = formatter.date(from: today) else { return 0 }
        
        if tDate.compare(eDate) == .orderedAscending {
            return 1
        } else {
            return today == exDate ? 1 : 0
        }
    }
    
    // MARK: - Timestamp Conversion
    class func convertUnixTimestamptoDateString(timestamp: String) -> String {
        guard let seconds = Double(timestamp) else { return "" }
        let date = Date(timeIntervalSince1970: seconds)
        return date.toString(format: .displayDate)
    }
    
    func getReadableDate(timeStamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeStamp / 1000)
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else if datFallsIncurrentWeek(date: date) {
            if Calendar.current.isDateInToday(date) {
                formatter.dateFormat = DateFormat.time12.rawValue
                return formatter.string(from: date)
            } else {
                formatter.dateFormat = DateFormat.fullDay.rawValue
                return formatter.string(from: date)
            }
        } else {
            formatter.dateFormat = DateFormat.fullDate.rawValue
            return formatter.string(from: date)
        }
    }
    
    func datFallsIncurrentWeek(date: Date) -> Bool {
        let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
        let datesWeek = Calendar.current.component(.weekOfYear, from: date)
        return currentWeek == datesWeek
    }
    
    // MARK: - TextField Concatenation
    class func concatStringOfTextFieldDelegate(text: String, string: String) -> String {
        var result = text + string
        if string.isEmpty, !result.isEmpty {
            result.removeLast()
        }
        return result
    }
    
    // MARK: - App Version
    class func getCurrentVersionOfApp() -> Float {
        if let bundle = Bundle.main.infoDictionary,
           let str = bundle["CFBundleShortVersionString"] as? String {
            return Float(str) ?? 0
        }
        return 0
    }
    
    // MARK: - Alerts
    private class func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return nil }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
    
    class func showAlert(title: CustomTitle, headings: [CustomAlert], completionHandler: AlertHandler?) {
        let alert = UIAlertController(title: nil, message: title.rawValue, preferredStyle: .alert)
        for (i, heading) in headings.enumerated() {
            alert.addAction(UIAlertAction(title: heading.rawValue, style: .default) { _ in
                completionHandler?(i)
            })
        }
        topViewController()?.present(alert, animated: true)
    }
    
    class func showAlertWithCustomTitle(title: String, message: String, headings: [CustomAlert], completionHandler: AlertHandler?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (i, heading) in headings.enumerated() {
            alert.addAction(UIAlertAction(title: heading.rawValue, style: .default) { _ in
                completionHandler?(i)
            })
        }
        topViewController()?.present(alert, animated: true)
    }
    
    class func showAlertWithCustomDoubleTitle(title: String, message: String, heading1: [CustomAlert], complitionHandler1: AlertHandler?, heading2: [CustomAlert], completionHandler2: AlertHandler?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for (i, heading) in heading1.enumerated() {
            alert.addAction(UIAlertAction(title: heading.rawValue, style: .default) { _ in
                complitionHandler1?(i)
            })
        }
        for (i, heading) in heading2.enumerated() {
            alert.addAction(UIAlertAction(title: heading.rawValue, style: .default) { _ in
                completionHandler2?(i)
            })
        }
        
        topViewController()?.present(alert, animated: true)
    }
    
    // MARK: - Time Conversion
    class func timeConversion12(time24: String) -> String {
        let df = DateFormatter()
        df.dateFormat = DateFormat.time24.rawValue
        guard let date = df.date(from: time24) else { return "" }
        df.dateFormat = DateFormat.time12.rawValue
        return df.string(from: date)
    }
}

// MARK: - Extensions
extension Date {
    func toString(format: DateFormat) -> String {
        let df = DateFormatter()
        df.dateFormat = format.rawValue
        return df.string(from: self)
    }
}

extension String {
    func toDate(format: DateFormat) -> Date? {
        let df = DateFormatter()
        df.dateFormat = format.rawValue
        return df.date(from: self)
    }
}
