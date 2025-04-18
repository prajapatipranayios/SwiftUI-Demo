//
//  Enumerations.swift
//  - Contains Global Configuration required for whole Tussly App like Fonts, Colors.

//  Tussly
//
//  Created by Jaimesh Patel on 05/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

enum Fonts
{
    case Regular, Bold, Italic, BoldItalic, Light, LightItalic, ExtraBold, ExtraBoldItalic, Semibold, SemiboldItalic
    
    func returnFont(size: CGFloat) -> UIFont {
        switch self {
            case .Regular:
                return UIFont(name: "OpenSans", size: size)!
            case .Bold:
                return UIFont(name: "OpenSans-Bold", size: size)!
            case .Italic:
                return UIFont(name: "OpenSans-Italic", size: size)!
            case .BoldItalic:
                return UIFont(name: "OpenSans-BoldItalic", size: size)!
            case .Light:
                return UIFont(name: "OpenSans-Light", size: size)!
            case .LightItalic:
                return UIFont(name: "OpenSansLight-Italic", size: size)!
            case .ExtraBold:
                return UIFont(name: "OpenSans-Extrabold", size: size)!
            case .ExtraBoldItalic:
                return UIFont(name: "OpenSans-ExtraboldItalic", size: size)!
            case .Semibold:
                return UIFont(name: "OpenSans-Semibold", size: size)!
            case .SemiboldItalic:
                return UIFont(name: "OpenSans-SemiboldItalic", size: size)!
        }
    }
}

enum Colors {
    case black, gray, lightGray, shadow, border, successMsg, wrongMsg, theme, themeDisable, validationMsg ,disable, stageRank, blueTheme, disableButton, themeSSBU, themeSSBM, discordBtn, activeButton, green, yellow, red
    
    func returnColor() -> UIColor {
        switch self {
            case .black:
                return UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 1.0)
            case .gray:
                return UIColor(red: 123.0/255.0, green: 123.0/255.0, blue: 123.0/255.0, alpha: 1.0)
            case .lightGray:
                return UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
            case .shadow:
                return UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 0.2)
            case .border:
                return UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
            case .successMsg:
                return UIColor(red: 48.0/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.0)
            case .wrongMsg:
                return UIColor(red: 198.0/255.0, green:26.0/255.0, blue:27.0/255.0, alpha:1.0)
            case .theme:
                return UIColor(red: 139.0/255.0, green:0.0/255.0, blue:0.0/255.0, alpha:1.0)
            case .themeDisable:
                return UIColor(red: 189.0/255.0, green:115.0/255.0, blue:116.0/255.0, alpha:1.0)
            case .validationMsg:
                return UIColor(red: 255.0/255.0, green:74.0/255.0, blue:64.0/255.0, alpha:1.0)
            case .disable:
                return UIColor(red: 221.0/255.0, green:221.0/255.0, blue:221.0/255.0, alpha:0.5)
            case .disableButton:
                return UIColor(red: 149.0/255.0, green:149.0/255.0, blue:149.0/255.0, alpha:1)
            case .stageRank:
                return UIColor(red: 50.0/255.0, green:76.0/255.0, blue:235.0/255.0, alpha:1)
            case .blueTheme:
                return UIColor(red: 0.0/255.0, green:174/255.0, blue:240/255.0, alpha:1)
            case .themeSSBU:
                return UIColor(red: 0.0/255.0, green: 184.0/255.0, blue: 246.0/255.0, alpha:1)
            case .themeSSBM:
                return UIColor(red: 226.0/255.0, green: 4.0/255.0, blue: 0.0/255.0, alpha:1)
            case .discordBtn:
                return UIColor(red: 114.0/255.0, green: 130.0/255.0, blue: 217.0/255.0, alpha:1)
            case .activeButton:
                return UIColor(red: 138/255.0, green: 7/255.0, blue: 2/255.0, alpha: 1)
            case .green:
                return UIColor(hexString: "#0DD146")
            case .yellow:
                return UIColor(hexString: "#FFCA19")
            case .red:
                return UIColor(hexString: "#ED1C25")
        }
    }
}

enum Gender: Int {
    case MALE = 0, FEMALE, OTHER, PREFER_NOT_TO_SAY
}

enum PlayerRole: Int {
    case MEMBER = 1, CAPTAIN, ADMIN, FOUNDER, ASSISTENT_CAPTAIN
}

enum AppInfo
{
    case AppTitle, DeviceId, Platform, GoogleClientID, GCMSenderId, YoutubeAPIKey  //Version, DeviceName, DeviceModel, AppType, GoogleClientID
    
    func returnAppInfo() -> String {
        switch self {
            case .AppTitle:
                return "Tussly"
//            case .Version:
//                return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
//            case .DeviceName:
//                return UIDevice.current.name
//            case .DeviceModel:
//                return UIDevice.current.model
            case .DeviceId:
                return (UIDevice.current.identifierForVendor?.uuidString)!
            case .Platform:
                return "IOS"
//            case .AppType:
//                return "1"
            case .GoogleClientID:
                return "544075321874-81icuj32b0loq67k0c8hp0ubkjqevm27.apps.googleusercontent.com"
            case .GCMSenderId:
                return "544075321874"
            case .YoutubeAPIKey:
                return "AIzaSyDRLDz7A624PlReDbH0cCzMiE6N7OO-M08"

        }
    }
}
