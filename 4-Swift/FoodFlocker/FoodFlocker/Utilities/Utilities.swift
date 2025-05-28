//
//  Utilities.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 25/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import AVFoundation
import Photos

class Utilities: NSObject {

    static func showPopup(title: String, type: AlertType) {
        DispatchQueue.main.async {
            if type == .success {
                let banner = Banner(title: nil, subtitle: title, image: nil, backgroundColor: Colors.themeGreen.returnColor())
                banner.dismissesOnTap = true
                banner.show(duration: 2.0)
            }else {
                let banner = Banner(title: nil, subtitle: title, image: nil, backgroundColor: Colors.red.returnColor())
                banner.dismissesOnTap = true
                banner.show(duration: 2.0)
            }
        }
    }
    
    static func displayActionSheetDatePicker(title: String, doneBlock: @escaping ActionDateDoneBlock, cancelBlock: @escaping ActionDateCancelBlock, origin: UIView) {
            
        let datePicker = ActionSheetDatePicker(title: title, datePickerMode: .dateAndTime, selectedDate: Date(), doneBlock: doneBlock, cancel: cancelBlock, origin: origin)
        
//            let stringPicker = ActionSheetStringPicker(title: title, rows: values, initialSelection: initialSelection, doneBlock: doneBlock, cancel: cancelBlock, origin: origin)

        datePicker?.titleTextAttributes = [NSAttributedString.Key.font: Fonts.Bold.returnFont(size: 16.0),
                                           NSAttributedString.Key.foregroundColor: UIColor.white]
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        datePicker?.pickerTextAttributes = [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0),
                                            NSAttributedString.Key.paragraphStyle: paragraph]
        datePicker?.toolbarBackgroundColor = Colors.themeGreen.returnColor()
        datePicker?.setTextColor(UIColor.black)
        datePicker?.toolbarButtonsColor = UIColor.white
        datePicker?.pickerBackgroundColor = UIColor.white
        datePicker?.pickerBlurRadius = 10.0
        
//        stringPicker?.setDoneButton(UIBarButtonItem(title: "Done", style: .done, target: <#T##Any?#>, action: <#T##Selector?#>))
        datePicker?.show()
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
            return "+" + countryDictionary[country]!
        } else {
            return ""
        }
    }
    
    static func setUserDefaultValue() {
        if !UserDefaults.standard.bool(forKey: UserDefaultType.isFirstTimeOnly) {
            UserDefaults.standard.set(true, forKey: UserDefaultType.isFirstTimeOnly)
            UserDefaults.standard.setValue("ForTestingFCMtoken", forKey: UserDefaultType.fcmToken)
        }
    }
    
    static func generateThumbnail(for asset:AVAsset) -> UIImage? {
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMake(value: 1, timescale: 2)
        let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        if img != nil {
            let frameImg  = UIImage(cgImage: img!)
           return frameImg
        }
        return nil
    }
    
    static func sortArrayDictDescendingForWinner(dict: [ChatMessage]) -> [ChatMessage] {
        return dict.sorted{ one, two in
            if one.createdAt == "Yesterday" && two.createdAt == "Today" {
                return one.createdAt > two.createdAt
            }else {
                return one.createdAt < two.createdAt
            }
        }
    }
    
    static func noDuplicates(_ arrayOfDicts: [ChatMessage]) -> [ChatMessage] {
        var noDuplicates = [ChatMessage]()
        var usedNames = [String]()
        for dict in arrayOfDicts {
            if let name = dict.messageDate, !usedNames.contains(dict.messageDate!) {
                noDuplicates.append(dict)
                usedNames.append(name)
            }
        }
        
        return noDuplicates
    }
    
    static func getLabelHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let lbl = UILabel(frame: .zero)
        lbl.frame.size.width = width
        lbl.font = font
        lbl.numberOfLines = 0
        lbl.text = text
        lbl.sizeToFit()

        return lbl.frame.size.height
    }
    
    static func convertDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy, hh:mma"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        return  dateFormatter.string(from: date!)

    }
    
    static func checkPhotoLibraryPermission() -> Bool {
        var value = true
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            case .authorized:
            //handle authorized status
                value = true
            case .denied, .restricted :
            //handle denied status
                value = false
            case .notDetermined:
                
                // ask for permissions
                PHPhotoLibrary.requestAuthorization { status in
                    switch status {
                    case .authorized:
                        value = true
                    // as above
                    case .denied, .restricted:
                        value = false
                    // as above
                    case .notDetermined:
                        value = false
                    default:
                        value = false
                    // won't happen but still
                    }
                }
            default:
                value = false
        }
        
        return value
    }
    
    static func isIphoneXAbove() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1136:
                    print("iPhone 5 or 5S or 5C")
                    return false
                case 1334:
                    print("iPhone 6/6S/7/8")
                    return false
                case 1920, 2208:
                    print("iPhone 6+/6S+/7+/8+")
                    return false
                case 2436:
                    print("iPhone X/XS/11 Pro")
                    return true
                case 2688:
                    print("iPhone XS Max/11 Pro Max")
                    return true
                case 1792:
                    print("iPhone XR/ 11 ")
                    return true
                default:
                    return true
            }
        } else {
            return false
        }
    }
    
    static func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
}
