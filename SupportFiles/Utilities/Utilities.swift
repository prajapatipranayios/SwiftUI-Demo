//
//  Utilities.swift
//  - Contains Utility methods which are accessible over any class file.

//  Tussly
//
//  Created by Jaimesh Patel on 15/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

class Utilities: NSObject {
    
    //"The Internet connection appears to be offline."
    static func showPopup(title: String, type: AlertType) {
        DispatchQueue.main.async {
            if type == .success {
                let banner = Banner(title: nil, subtitle: title, image: nil, backgroundColor: Colors.successMsg.returnColor())
                banner.dismissesOnTap = true
                banner.show(duration: 2.0)
            }
            else {
                let banner = Banner(title: nil, subtitle: title == "" ? "Something Went Wrong!!" : title, image: nil, backgroundColor: Colors.wrongMsg.returnColor())
                banner.dismissesOnTap = true
                banner.show(duration: 2.0)
            }
        }
    }
    
    static func getCountryPhoneCode (country : String) -> String
    {
        let countryDictionary  = ["AF":"93",
                                  "AL":"355",
                                  "DZ":"213",
                                  "AS":"1",
                                  "AD":"376",
                                  "AO":"244",
                                  "AI":"1",
                                  "AG":"1",
                                  "AR":"54",
                                  "AM":"374",
                                  "AW":"297",
                                  "AU":"61",
                                  "AT":"43",
                                  "AZ":"994",
                                  "BS":"1",
                                  "BH":"973",
                                  "BD":"880",
                                  "BB":"1",
                                  "BY":"375",
                                  "BE":"32",
                                  "BZ":"501",
                                  "BJ":"229",
                                  "BM":"1",
                                  "BT":"975",
                                  "BA":"387",
                                  "BW":"267",
                                  "BR":"55",
                                  "IO":"246",
                                  "BG":"359",
                                  "BF":"226",
                                  "BI":"257",
                                  "KH":"855",
                                  "CM":"237",
                                  "CA":"1",
                                  "CV":"238",
                                  "KY":"345",
                                  "CF":"236",
                                  "TD":"235",
                                  "CL":"56",
                                  "CN":"86",
                                  "CX":"61",
                                  "CO":"57",
                                  "KM":"269",
                                  "CG":"242",
                                  "CK":"682",
                                  "CR":"506",
                                  "HR":"385",
                                  "CU":"53",
                                  "CY":"537",
                                  "CZ":"420",
                                  "DK":"45",
                                  "DJ":"253",
                                  "DM":"1",
                                  "DO":"1",
                                  "EC":"593",
                                  "EG":"20",
                                  "SV":"503",
                                  "GQ":"240",
                                  "ER":"291",
                                  "EE":"372",
                                  "ET":"251",
                                  "FO":"298",
                                  "FJ":"679",
                                  "FI":"358",
                                  "FR":"33",
                                  "GF":"594",
                                  "PF":"689",
                                  "GA":"241",
                                  "GM":"220",
                                  "GE":"995",
                                  "DE":"49",
                                  "GH":"233",
                                  "GI":"350",
                                  "GR":"30",
                                  "GL":"299",
                                  "GD":"1",
                                  "GP":"590",
                                  "GU":"1",
                                  "GT":"502",
                                  "GN":"224",
                                  "GW":"245",
                                  "GY":"595",
                                  "HT":"509",
                                  "HN":"504",
                                  "HU":"36",
                                  "IS":"354",
                                  "IN":"91",
                                  "ID":"62",
                                  "IQ":"964",
                                  "IE":"353",
                                  "IL":"972",
                                  "IT":"39",
                                  "JM":"1",
                                  "JP":"81",
                                  "JO":"962",
                                  "KZ":"77",
                                  "KE":"254",
                                  "KI":"686",
                                  "KW":"965",
                                  "KG":"996",
                                  "LV":"371",
                                  "LB":"961",
                                  "LS":"266",
                                  "LR":"231",
                                  "LI":"423",
                                  "LT":"370",
                                  "LU":"352",
                                  "MG":"261",
                                  "MW":"265",
                                  "MY":"60",
                                  "MV":"960",
                                  "ML":"223",
                                  "MT":"356",
                                  "MH":"692",
                                  "MQ":"596",
                                  "MR":"222",
                                  "MU":"230",
                                  "YT":"262",
                                  "MX":"52",
                                  "MC":"377",
                                  "MN":"976",
                                  "ME":"382",
                                  "MS":"1",
                                  "MA":"212",
                                  "MM":"95",
                                  "NA":"264",
                                  "NR":"674",
                                  "NP":"977",
                                  "NL":"31",
                                  "AN":"599",
                                  "NC":"687",
                                  "NZ":"64",
                                  "NI":"505",
                                  "NE":"227",
                                  "NG":"234",
                                  "NU":"683",
                                  "NF":"672",
                                  "MP":"1",
                                  "NO":"47",
                                  "OM":"968",
                                  "PK":"92",
                                  "PW":"680",
                                  "PA":"507",
                                  "PG":"675",
                                  "PY":"595",
                                  "PE":"51",
                                  "PH":"63",
                                  "PL":"48",
                                  "PT":"351",
                                  "PR":"1",
                                  "QA":"974",
                                  "RO":"40",
                                  "RW":"250",
                                  "WS":"685",
                                  "SM":"378",
                                  "SA":"966",
                                  "SN":"221",
                                  "RS":"381",
                                  "SC":"248",
                                  "SL":"232",
                                  "SG":"65",
                                  "SK":"421",
                                  "SI":"386",
                                  "SB":"677",
                                  "ZA":"27",
                                  "GS":"500",
                                  "ES":"34",
                                  "LK":"94",
                                  "SD":"249",
                                  "SR":"597",
                                  "SZ":"268",
                                  "SE":"46",
                                  "CH":"41",
                                  "TJ":"992",
                                  "TH":"66",
                                  "TG":"228",
                                  "TK":"690",
                                  "TO":"676",
                                  "TT":"1",
                                  "TN":"216",
                                  "TR":"90",
                                  "TM":"993",
                                  "TC":"1",
                                  "TV":"688",
                                  "UG":"256",
                                  "UA":"380",
                                  "AE":"971",
                                  "GB":"44",
                                  "US":"1",
                                  "UY":"598",
                                  "UZ":"998",
                                  "VU":"678",
                                  "WF":"681",
                                  "YE":"967",
                                  "ZM":"260",
                                  "ZW":"263",
                                  "BO":"591",
                                  "BN":"673",
                                  "CC":"61",
                                  "CD":"243",
                                  "CI":"225",
                                  "FK":"500",
                                  "GG":"44",
                                  "VA":"379",
                                  "HK":"852",
                                  "IR":"98",
                                  "IM":"44",
                                  "JE":"44",
                                  "KP":"850",
                                  "KR":"82",
                                  "LA":"856",
                                  "LY":"218",
                                  "MO":"853",
                                  "MK":"389",
                                  "FM":"691",
                                  "MD":"373",
                                  "MZ":"258",
                                  "PS":"970",
                                  "PN":"872",
                                  "RE":"262",
                                  "RU":"7",
                                  "BL":"590",
                                  "SH":"290",
                                  "KN":"1",
                                  "LC":"1",
                                  "MF":"590",
                                  "PM":"508",
                                  "VC":"1",
                                  "ST":"239",
                                  "SO":"252",
                                  "SJ":"47",
                                  "SY":"963",
                                  "TW":"886",
                                  "TZ":"255",
                                  "TL":"670",
                                  "VE":"58",
                                  "VN":"84",
                                  "VG":"284",
                                  "VI":"340"]
        if countryDictionary[country] != nil {
            return countryDictionary[country]!
        } else {
            return ""
        }
    }
    
    static func convertDateToString(date: Date, CurrentDateFormate: String = "MMM d, yyyy h:mm a", NewDateFormate: String = "MMM d, yyyy h:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NewDateFormate //Specify your format that you want
        return (dateFormatter.string(from: date))
    }
    
    static func convertStringToDate(date: String, CurrentDateFormate: String = "MMM d, yyyy h:mm a", NewDateFormate: String = "MMM d, yyyy h:mm a") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NewDateFormate //Specify your format that you want
        return (dateFormatter.date(from: date)! )
    }
    
    static func convertStrDateToString(date: String, CurrentDateFormate: String = "MMM d, yyyy h:mm a", NewDateFormate: String = "MMM d, yyyy h:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = CurrentDateFormate
        let date = dateFormatter.date(from: date)!
        dateFormatter.dateFormat = NewDateFormate
        return (dateFormatter.string(from: date))
    }
    
    static func convertTimestamptoDateString(timestamp: Int, dateFormate: String = "MMM d, yyyy h:mm a") -> String {
        //let date = Date(timeIntervalSince1970: Double(timestamp)!)
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = dateFormate //Specify your format that you want
        let msgDate : String = dateFormatter.string(from: date)
        return msgDate  //dateFormatter.string(from: date)
    }
    
    static func getStrDateAdding(days: Int, dateFormate: String = "MMM d, yyyy h:mm a") -> String {
        let modifiedDate = Calendar.current.date(byAdding: .day, value: days, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormate //Specify your format that you want
        return (dateFormatter.string(from: modifiedDate!))
    }
    
    /// Set two date to display proper like '14 Jul 2024 to 10 Aug 2024' to '14 Jul to 10 Aug 2024'
    static func setDateToProparDisplay(startDate: String, endDate: String, currentDateFormate: String = "dd-MMMM-yyyy", newDateFormateDay: String = "dd", newDateFormateMonth: String = "MMM", newDateFormateYear: String = "yyyy", dateFormatSeparator: String = "-") -> String {
        
        let fullDateFormate: String = "\(newDateFormateDay) \(newDateFormateMonth) \(newDateFormateYear)".replacingOccurrences(of: " ", with: dateFormatSeparator)
        let dayMonthDateFormate: String = "\(newDateFormateDay) \(newDateFormateMonth)".replacingOccurrences(of: " ", with: dateFormatSeparator)
        let dayDateFormate: String = "\(newDateFormateDay)"
        
        let startDateComponent = Calendar.current.dateComponents([.day, .month, .year], from: Utilities.convertStringToDate(date: startDate, CurrentDateFormate: currentDateFormate, NewDateFormate: fullDateFormate))
        
        let endDateComponent = Calendar.current.dateComponents([.day, .month, .year], from: Utilities.convertStringToDate(date: endDate, CurrentDateFormate: currentDateFormate, NewDateFormate: fullDateFormate))
        
        var date: String = ""
        if (startDateComponent.year ?? 0) == (endDateComponent.year ?? 0) {
            date = "\(Utilities.convertStrDateToString(date: startDate, CurrentDateFormate: currentDateFormate, NewDateFormate: dayMonthDateFormate)) to \(Utilities.convertStrDateToString(date: endDate, CurrentDateFormate: currentDateFormate, NewDateFormate: fullDateFormate))"
            
            if ((startDateComponent.month ?? 0) == (endDateComponent.month ?? 0)) {
                
                date = "\(Utilities.convertStrDateToString(date: startDate, CurrentDateFormate: currentDateFormate, NewDateFormate: dayDateFormate)) to \(Utilities.convertStrDateToString(date: endDate, CurrentDateFormate: currentDateFormate, NewDateFormate: fullDateFormate))"
                
                if ((startDateComponent.day ?? 0) == (endDateComponent.day ?? 0)) {
                    date = "\(Utilities.convertStrDateToString(date: startDate, CurrentDateFormate: currentDateFormate, NewDateFormate: fullDateFormate))"
                }
            }
        }
        else {
            date = "\(Utilities.convertStrDateToString(date: startDate, CurrentDateFormate: currentDateFormate, NewDateFormate: fullDateFormate)) to \(Utilities.convertStrDateToString(date: endDate, CurrentDateFormate: currentDateFormate, NewDateFormate: fullDateFormate))"
        }
        return date
    }
    
    static func categorizeDate(from dateString: String, inputFormat: String = "dd MMM,yyyy", outputFormat: String = "dd MMM,yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = inputFormat
        
        guard let date = dateFormatter.date(from: dateString) else {
            return "Invalid date format"
        }
        
        let calendar = Calendar.current
        
        // Check if the date is today
        if calendar.isDateInToday(date) {
            return "Today"
        }
        // Check if the date is yesterday
        else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }
        // Check if the date is in the current week
        //else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
        //    return "This Week"
        //}
        
        // Return the date in the desired output format
        dateFormatter.dateFormat = outputFormat
        return dateFormatter.string(from: date)
    }
    
    static func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    static func MD5(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    
    class func imageFrom(name: String?) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = .lightGray
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        var initials = ""
        if let initialsArray = name?.components(separatedBy: " ") {
            if let firstWord = initialsArray.first {
                if let firstLetter = firstWord.first {
                    initials += String(firstLetter).capitalized }
            }
            if initialsArray.count > 1, let lastWord = initialsArray.last {
                if let lastLetter = lastWord.first { initials += String(lastLetter).capitalized
                }
            }
        } else {
            return nil
        }
        nameLabel.text = initials
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }
    
    class func randomColor() -> UIColor {
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    class func addLabelToImage(image: UIImage, label: UILabel) -> UIImage? {
        let tempView = UIStackView(frame: CGRect(x: 0, y: 0, width: 90, height: 60))
        //let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.height))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.contentMode = .scaleAspectFit
        tempView.axis = .vertical
        tempView.alignment = .center
        tempView.spacing = 1
        imageView.image = image
        tempView.addArrangedSubview(imageView)
        tempView.addArrangedSubview(label)
        let renderer = UIGraphicsImageRenderer(bounds: tempView.bounds)
        let image = renderer.image { rendererContext in
            tempView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
    
    class func fileName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "ddMMyyyyhmmss"
        
        return formatter.string(from: Date())
    }
    
    static func convertJsonToString(json: [String: Any]) -> String {
        do {
            let data1 = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) as NSString? ?? ""
            debugPrint(convertedString)
            return convertedString as String
        } catch let myJSONError {
            debugPrint(myJSONError)
            return ""
        }
    }
    
    static func convertJSONStringtoJSON(_ jsonString: String) -> Any? {
      guard let data = jsonString.data(using: .utf8) else { return nil }
      
      do {
        return try JSONSerialization.jsonObject(with: data, options: [])
      } catch let error {
        debugPrint("Error parsing JSON: \(error)")
        return nil
      }
    }
}
