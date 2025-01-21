//
//  CurrencyFormatter.swift
//  SwiftDemo1
//
//  Created by Auxano on 21/01/25.
//

import Foundation

class CurrencyFormatter {
    static func formattedCurrency(for currency: CountryCurrency, amount: Double) -> (symbol: String, formattedAmount: String)? {
        let formatter : NumberFormatter = {
            //let PRICE_FORMAT = "#,##,###.##"
            let PRICE_FORMAT = currency.format
            let formatter = NumberFormatter()
            formatter.locale = .current
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = true
            //formatter.groupingSeparator = ","
            //let formatter = NumberFormatter()
            //formatter.numberStyle = .decimal
            formatter.positiveFormat = PRICE_FORMAT
            return formatter
        }()
        
        //let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        
        guard let symbol = formatter.currencySymbol,
              let formattedAmount = formatter.string(from: NSNumber(value: amount)) else {
            return nil
        }
        
        //return (symbol, unicode, formattedAmount)
        return (currency.symbol, "\(currency.symbol)\(formattedAmount)")
        
        let numberFormatter: NumberFormatter = NumberFormatter.INDCurrencyFormate
        
        /*if let stringAsNumber = Double(self) {
            let numberNS = NSNumber(value: stringAsNumber)
            return numberFormatter.string(from: numberNS)!
        }   //  */
        
//        if let number = Double (self) {
//            return numberFormatter.string(from: NSNumber(value: number)) ?? self
//        }
//        return "That value is not a number. Try again."
    }
}

enum CountryCurrency: String, CaseIterable {
    case INR = "INR" // Indian Rupee
    case RUB = "RUB" // Russian Ruble
    case USD = "USD" // United States Dollar
    case GBP = "GBP" // British Pound
    case AED = "AED" // United Arab Emirates Dirham
    case JPY = "JPY" // Japanese Yen
    case AFN = "AFN" // Afghan Afghani
    case ALL = "ALL" // Albanian Lek
    case DZD = "DZD" // Algerian Dinar
    case AOA = "AOA" // Angolan Kwanza
    case ARS = "ARS" // Argentine Peso
    case AUD = "AUD" // Australian Dollar
    case AZN = "AZN" // Azerbaijani Manat
    case BHD = "BHD" // Bahraini Dinar
    case BDT = "BDT" // Bangladeshi Taka
    case BYN = "BYN" // Belarusian Ruble
    case BZD = "BZD" // Belize Dollar
    case BMD = "BMD" // Bermudian Dollar
    case BTN = "BTN" // Bhutanese Ngultrum
    case BOB = "BOB" // Bolivian Boliviano
    case BAM = "BAM" // Bosnia and Herzegovina Convertible Mark
    case BWP = "BWP" // Botswana Pula
    case BRL = "BRL" // Brazilian Real
    case BGN = "BGN" // Bulgarian Lev
    case CAD = "CAD" // Canadian Dollar
    case CLP = "CLP" // Chilean Peso
    case CNY = "CNY" // Chinese Yuan Renminbi
    case COP = "COP" // Colombian Peso
    case CRC = "CRC" // Costa Rican Colón
    case HRK = "HRK" // Croatian Kuna
    case CUP = "CUP" // Cuban Peso
    case CZK = "CZK" // Czech Koruna
    case DKK = "DKK" // Danish Krone
    case DOP = "DOP" // Dominican Peso
    case EGP = "EGP" // Egyptian Pound
    case ETB = "ETB" // Ethiopian Birr
    case EUR = "EUR" // Euro
    case FJD = "FJD" // Fijian Dollar
    case GEL = "GEL" // Georgian Lari
    case GHS = "GHS" // Ghanaian Cedi
    case GTQ = "GTQ" // Guatemalan Quetzal
    case HKD = "HKD" // Hong Kong Dollar
    case HUF = "HUF" // Hungarian Forint
    case ISK = "ISK" // Icelandic Króna
    case IDR = "IDR" // Indonesian Rupiah
    case IRR = "IRR" // Iranian Rial
    case IQD = "IQD" // Iraqi Dinar
    case ILS = "ILS" // Israeli New Shekel
    case JMD = "JMD" // Jamaican Dollar
    case JOD = "JOD" // Jordanian Dinar
    case KZT = "KZT" // Kazakhstani Tenge
    case KES = "KES" // Kenyan Shilling
    case KRW = "KRW" // South Korean Won
    case KWD = "KWD" // Kuwaiti Dinar
    case KGS = "KGS" // Kyrgyzstani Som
    case LAK = "LAK" // Lao Kip
    case LBP = "LBP" // Lebanese Pound
    case LYD = "LYD" // Libyan Dinar
    case MYR = "MYR" // Malaysian Ringgit
    case MVR = "MVR" // Maldivian Rufiyaa
    case MUR = "MUR" // Mauritian Rupee
    case MXN = "MXN" // Mexican Peso
    case MDL = "MDL" // Moldovan Leu
    case MNT = "MNT" // Mongolian Tögrög
    case MAD = "MAD" // Moroccan Dirham
    case MMK = "MMK" // Myanmar Kyat
    case NAD = "NAD" // Namibian Dollar
    case NPR = "NPR" // Nepalese Rupee
    case NZD = "NZD" // New Zealand Dollar
    case NGN = "NGN" // Nigerian Naira
    case NOK = "NOK" // Norwegian Krone
    case OMR = "OMR" // Omani Rial
    case PKR = "PKR" // Pakistani Rupee
    case PAB = "PAB" // Panamanian Balboa
    case PGK = "PGK" // Papua New Guinean Kina
    case PEN = "PEN" // Peruvian Sol
    case PHP = "PHP" // Philippine Peso
    case PLN = "PLN" // Polish Złoty
    case QAR = "QAR" // Qatari Riyal
    case RON = "RON" // Romanian Leu
    case RWF = "RWF" // Rwandan Franc
    case SAR = "SAR" // Saudi Riyal
    case RSD = "RSD" // Serbian Dinar
    case SCR = "SCR" // Seychellois Rupee
    case SGD = "SGD" // Singapore Dollar
    case ZAR = "ZAR" // South African Rand
    case LKR = "LKR" // Sri Lankan Rupee
    case SEK = "SEK" // Swedish Krona
    case CHF = "CHF" // Swiss Franc
    case TWD = "TWD" // Taiwan Dollar
    case TZS = "TZS" // Tanzanian Shilling
    case THB = "THB" // Thai Baht
    case TOP = "TOP" // Tongan Paʻanga
    case TRY = "TRY" // Turkish Lira
    case UGX = "UGX" // Ugandan Shilling
    case UAH = "UAH" // Ukrainian Hryvnia
    case UYU = "UYU" // Uruguayan Peso
    case UZS = "UZS" // Uzbekistani Som
    case VND = "VND" // Vietnamese Đồng
    case YER = "YER" // Yemeni Rial
    case ZMW = "ZMW" // Zambian Kwacha
    
    // Currency-specific format
    var format: String {
        switch self {
        case .INR: return "#,##,###.##" // Indian numbering system
        case .USD: return "###,###.##" // US numbering system
        case .EUR: return "###,###.##" // Similar to USD
        case .JPY: return "###,###.##" // No decimal places for JPY
        case .GBP: return "###,###.##" // British numbering system
        case .AUD, .CAD, .CNY: return "###,###.##" // Common with USD format
        case .RUB, .AED, .AFN, .ALL, .DZD, .AOA, .ARS, .AZN, .BHD, .BDT: return "###,###.##" // Common with USD format
        case .BYN, .BZD, .BMD, .BTN, .BOB, .BAM, .BWP, .BRL, .BGN, .CLP: return "###,###.##" // Common with USD format
        case .COP, .CRC, .HRK, .CUP, .CZK, .DKK, .DOP, .EGP, .ETB, .FJD: return "###,###.##" // Common with USD format
        case .GEL, .GHS, .GTQ, .HKD, .HUF, .ISK, .IDR, .IRR, .IQD, .ILS: return "###,###.##" // Common with USD format
        case .JMD, .JOD, .KZT, .KES, .KRW, .KWD, .KGS, .LAK, .LBP, .LYD: return "###,###.##" // Common with USD format
        case .MYR, .MVR, .MUR, .MXN, .MDL, .MNT, .MAD, .MMK, .NAD, .NPR: return "###,###.##" // Common with USD format
        case .NZD, .NGN, .NOK, .OMR, .PKR, .PAB, .PGK, .PEN, .PHP, .PLN: return "###,###.##" // Common with USD format
        case .QAR, .RON, .RWF, .SAR, .RSD, .SCR, .SGD, .ZAR, .LKR, .SEK: return "###,###.##" // Common with USD format
        case .CHF, .TWD, .TZS, .THB, .TOP, .TRY, .UGX, .UAH, .UYU, .UZS: return "###,###.##" // Common with USD format
        case .VND, .YER, .ZMW: return "###,###.##" // Common with USD format
        }
    }
    
    var symbol: String {
        switch self {
        case .INR:
            "₹"
        case .RUB:
            "₽"
        case .USD:
            "$"
        case .GBP:
            "£"
        case .AED:
            "د.إ"
        case .JPY:
            "¥"
        case .AFN:
            "؋"
        case .ALL:
            "L"
        case .DZD:
            "دج"
        case .AOA:
            "Kz"
        case .ARS:
            "$"
        case .AUD:
            "A$"
        case .AZN:
            "₼"
        case .BHD:
            ".د.ب"
        case .BDT:
            "৳"
        case .BYN:
            "Br"
        case .BZD:
            "BZ$"
        case .BMD:
            "$"
        case .BTN:
            "Nu."
        case .BOB:
            "Bs."
        case .BAM:
            "KM"
        case .BWP:
            "P"
        case .BRL:
            "R$"
        case .BGN:
            "лв"
        case .CAD:
            "C$"
        case .CLP:
            "$"
        case .CNY:
            "¥"
        case .COP:
            "$"
        case .CRC:
            "₡"
        case .HRK:
            "kn"
        case .CUP:
            "$"
        case .CZK:
            "Kč"
        case .DKK:
            "kr"
        case .DOP:
            "RD$"
        case .EGP:
            "ج.م"
        case .ETB:
            "Br"
        case .EUR:
            "€"
        case .FJD:
            "FJ$"
        case .GEL:
            "₾"
        case .GHS:
            "₵"
        case .GTQ:
            "Q"
        case .HKD:
            "HK$"
        case .HUF:
            "Ft"
        case .ISK:
            "kr"
        case .IDR:
            "Rp"
        case .IRR:
            "﷼"
        case .IQD:
            "ع.د"
        case .ILS:
            "₪"
        case .JMD:
            "J$"
        case .JOD:
            "د.ا"
        case .KZT:
            "₸"
        case .KES:
            "KSh"
        case .KRW:
            "₩"
        case .KWD:
            "د.ك"
        case .KGS:
            "лв"
        case .LAK:
            "₭"
        case .LBP:
            "ل.ل"
        case .LYD:
            "ل.د"
        case .MYR:
            "RM"
        case .MVR:
            ".ރ"
        case .MUR:
            "₨"
        case .MXN:
            "MX$"
        case .MDL:
            "L"
        case .MNT:
            "₮"
        case .MAD:
            "د.م."
        case .MMK:
            "Ks"
        case .NAD:
            "N$"
        case .NPR:
            "₨"
        case .NZD:
            "NZ$"
        case .NGN:
            "₦"
        case .NOK:
            "kr"
        case .OMR:
            "﷼"
        case .PKR:
            "₨"
        case .PAB:
            "B/."
        case .PGK:
            "K"
        case .PEN:
            "S/."
        case .PHP:
            "₱"
        case .PLN:
            "zł"
        case .QAR:
            "﷼"
        case .RON:
            "lei"
        case .RWF:
            "FRw"
        case .SAR:
            "﷼"
        case .RSD:
            "дин."
        case .SCR:
            "₨"
        case .SGD:
            "S$"
        case .ZAR:
            "R"
        case .LKR:
            "රු"
        case .SEK:
            "kr"
        case .CHF:
            "CHF"
        case .TWD:
            "NT$"
        case .TZS:
            "TSh"
        case .THB:
            "฿"
        case .TOP:
            "T$"
        case .TRY:
            "₺"
        case .UGX:
            "USh"
        case .UAH:
            "₴"
        case .UYU:
            "$U"
        case .UZS:
            "сўм"
        case .VND:
            "₫"
        case .YER:
            "﷼"
        case .ZMW:
            "ZK"
        }
    }
}

extension String {
    func curFormatAsRegion(for currency: CountryCurrency = .INR, numberStyle: NumberFormatter.Style = .decimal, groupingSeparator: String = ",") -> String {
        
        let numberFormatter : NumberFormatter = {
            //let PRICE_FORMAT = "#,##,###.##"
            let PRICE_FORMAT = currency.format
            let formatter = NumberFormatter()
            formatter.locale = .current
            formatter.numberStyle = numberStyle
            formatter.usesGroupingSeparator = true
            //formatter.groupingSeparator = ","
            //let formatter = NumberFormatter()
            //formatter.numberStyle = .decimal
            formatter.positiveFormat = PRICE_FORMAT
            return formatter
        }()
        
        if let number = Double (self) {
            return "\(currency.symbol)s\(numberFormatter.string(from: NSNumber(value: number)) ?? self)"
        }
        return "That value is not a number. Try again."
    }
}

extension NumberFormatter {
    static let INDCurrencyFormate: NumberFormatter = {
        let PRICE_FORMAT = "#,##,###.##"
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        //formatter.groupingSeparator = ","
        //let formatter = NumberFormatter()
        //formatter.numberStyle = .decimal
        formatter.positiveFormat = PRICE_FORMAT
        return formatter
    }()
}
