//
//  Utilities.swift
//  - Contains Utility methods which are accessible over any class file.

//  Tussly
//
//  Created by Jaimesh Patel on 15/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class Utilities: NSObject {
    
    static func getRoleName(roleId: Int) -> String {
        if roleId == 1 {
            return "Member"
        } else if roleId == 2 {
            return "Captain"
        } else if roleId == 3 {
            return "Admin"
        } else if roleId == 4 {
            return "Founder"
        } else if roleId == 5 {
            return "AssistantCaptain"
        } else {
            return ""
        }
    }
    
    //"The Internet connection appears to be offline."
    static func showPopup(title: String, type: AlertType) {
        DispatchQueue.main.async {
            if type == .success {
                let banner = Banner(title: nil, subtitle: title, image: nil, backgroundColor: Colors.successMsg.returnColor())
                banner.dismissesOnTap = true
                banner.show(duration: 2.0)
            }else {
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
    
    /// By Pranay
    static func getGameColor(gameId: Int) -> UIColor {
        if gameId == 11 {
            return Colors.themeSSBU.returnColor()
        } else if gameId == 13 {
            return Colors.themeSSBM.returnColor()
        } else if gameId == 14 {
            return Colors.theme.returnColor()
        }
        return UIColor.white
    }
    
    static func convertTimestamptoDateString(timestamp: Int) -> String {
        //let date = Date(timeIntervalSince1970: Double(timestamp)!)
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a" //Specify your format that you want
        let msgDate : String = dateFormatter.string(from: date)
        return msgDate  //dateFormatter.string(from: date)
    }
    
    static func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    static func convertTimestampToLastMsgDateTimeString(timestamp: String, dateFormat: String = "dd MMM, yyyy") -> String {
        guard let timeInterval = Double(timestamp) else { return "" }
        let messageDate = Date(timeIntervalSince1970: timeInterval)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = dateFormat
        
        let msgDateStr = dateFormatter.string(from: messageDate)
        let todayDateStr = dateFormatter.string(from: Date())
        
        if msgDateStr == todayDateStr {
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: messageDate)
        } else {
            return formatPastMessageDate(msgDateStr: msgDateStr)
        }
    }

    fileprivate static func formatPastMessageDate(msgDateStr: String, dateFormat: String = "dd MMM, yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        guard let msgDate = dateFormatter.date(from: msgDateStr) else { return "" }
        
        if Calendar.current.isDateInYesterday(msgDate) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = dateFormat
            return dateFormatter.string(from: msgDate)
        }
    }
    
    class func convertTimestamptoTimeString(timestamp: String) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp)!)
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter.string(from: date)
    }
    
    enum TimestampFormatStyle {
        case timeOnly               // "5:00 PM"
        case dateOnly               // "16 Apr, 2025"
        case dateTime               // "16 Apr, 2025 12:32 AM"
        case relativeDay            // "Today", "Yesterday", or "16 Apr, 2025"
        case relativeDayWithTime    // "Today, 5:00 PM", "Yesterday, 5:00 PM", or "16 Apr, 2025 12:32 AM"
    }

    class func formatTimestamp(_ timestamp: String, style: TimestampFormatStyle = .timeOnly) -> String {
        // Validate timestamp
        guard !timestamp.isEmpty, let timeInterval = TimeInterval(timestamp) else {
            return "Invalid timestamp"
        }
        
        let date = Date(timeIntervalSince1970: timeInterval)
        let calendar = Calendar.current
        let now = Date()
        
        // Configure date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        
        switch style {
        case .timeOnly:
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: date)
            
        case .dateOnly:
            dateFormatter.dateFormat = "d MMM, yyyy"
            return dateFormatter.string(from: date)
            
        case .dateTime:
            dateFormatter.dateFormat = "d MMM, yyyy h:mm a"
            return dateFormatter.string(from: date)
            
        case .relativeDay:
            if calendar.isDateInToday(date) {
                return "Today"
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                dateFormatter.dateFormat = "d MMM, yyyy"
                return dateFormatter.string(from: date)
            }
            
        case .relativeDayWithTime:
            dateFormatter.dateFormat = "h:mm a"
            let timeString = dateFormatter.string(from: date)
            
            if calendar.isDateInToday(date) {
                return "Today, \(timeString)"
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday, \(timeString)"
            } else {
                dateFormatter.dateFormat = "d MMM, yyyy h:mm a"
                return dateFormatter.string(from: date)
            }
        }
    }
    
    enum ImagePosition {
        case left
        case right
    }
    enum TextStyle {
        case regular
        case bold
        case italic
        case underline
        case boldItalic
    }
    static func attributedTextWithImage(
        text: String,
        image: UIImage,
        imageSize: CGSize = CGSize(width: 16, height: 16),
        imagePosition: ImagePosition = .left,
        imageColor: UIColor? = nil,
        textStyle: TextStyle = .regular,
        fontSize: CGFloat = 14
    ) -> NSAttributedString {
        
        let attachment = NSTextAttachment()
        
        if let imageColor = imageColor {
            attachment.image = image.withRenderingMode(.alwaysTemplate)
            let imageView = UIImageView(image: attachment.image)
            imageView.tintColor = imageColor
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
            imageView.frame = CGRect(origin: .zero, size: imageSize)
            imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            attachment.image = coloredImage
        } else {
            attachment.image = image
        }

        attachment.bounds = CGRect(x: 0, y: -2, width: imageSize.width, height: imageSize.height)
        
        let imageString = NSAttributedString(attachment: attachment)
        let space = NSAttributedString(string: " ")
        
        // Style the text
        var attributes: [NSAttributedString.Key: Any] = [:]
        switch textStyle {
        case .regular:
            attributes[.font] = UIFont.systemFont(ofSize: fontSize)
        case .bold:
            attributes[.font] = UIFont.boldSystemFont(ofSize: fontSize)
        case .italic:
            attributes[.font] = UIFont.italicSystemFont(ofSize: fontSize)
        case .underline:
            attributes[.font] = UIFont.systemFont(ofSize: fontSize)
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        case .boldItalic:
            if let descriptor = UIFont.systemFont(ofSize: fontSize).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic]) {
                attributes[.font] = UIFont(descriptor: descriptor, size: fontSize)
            } else {
                attributes[.font] = UIFont.boldSystemFont(ofSize: fontSize)
            }
        }

        let textString = NSAttributedString(string: text, attributes: attributes)
        
        let final = NSMutableAttributedString()
        
        if imagePosition == .left {
            final.append(imageString)
            final.append(space)
            final.append(textString)
        } else {
            final.append(textString)
            final.append(space)
            final.append(imageString)
        }
        
        return final
    }
    
}
