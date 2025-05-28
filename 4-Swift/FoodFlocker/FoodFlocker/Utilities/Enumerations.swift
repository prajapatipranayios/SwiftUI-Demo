//
//  Enumerations.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 20/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

enum Colors {
    
    case themeGreen, gray, lightGray, red, orange, green, inactiveButton, light, yellowStar
    
    func returnColor() -> UIColor {
        switch self {
            case .themeGreen: //93C572
                return UIColor(red: 147.0/255.0, green: 197.0/255.0, blue: 114.0/255.0, alpha: 1.0)
            case .gray: //5A5A5A
                return UIColor(red: 90.0/255.0, green: 90.0/255.0, blue: 90.0/255.0, alpha: 1.0)
            case .lightGray: //ACACAC
                return UIColor(red: 172.0/255.0, green: 172.0/255.0, blue: 172.0/255.0, alpha: 1.0)
            case .red: //FF0800
                return UIColor(red: 255.0/255.0, green: 8.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            case .orange: //FA9300
                return UIColor(red: 250.0/255.0, green: 147.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            case .green: //368800
                return UIColor(red: 54.0/255.0, green: 136.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            case .inactiveButton: //919191
                return UIColor(red: 145.0/255.0, green: 145.0/255.0, blue: 145.0/255.0, alpha: 1.0)
            case .light: //f1f1f1
                return UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)
            case .yellowStar: //f1f1f1
                return UIColor(red: 250.0/255.0, green: 147.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        }
    }
}

enum Fonts
{
    case Regular, Bold, Italic, BoldItalic, Light, LightItalic, ExtraBold, ExtraBoldItalic, Semibold, SemiboldItalic, Medium
    
    func returnFont(size: CGFloat) -> UIFont {
        switch self {
            case .Regular:
                return UIFont(name: "Poppins-Regular", size: size)!
            case .Bold:
                return UIFont(name: "Poppins-Bold", size: size)!
            case .Italic:
                return UIFont(name: "Poppins-Italic", size: size)!
            case .BoldItalic:
                return UIFont(name: "Poppins-BoldItalic", size: size)!
            case .Light:
                return UIFont(name: "Poppins-Light", size: size)!
            case .LightItalic:
                return UIFont(name: "Poppins-LightItalic", size: size)!
            case .ExtraBold:
                return UIFont(name: "Poppins-ExtraBold", size: size)!
            case .ExtraBoldItalic:
                return UIFont(name: "Poppins-ExtraBoldItalic", size: size)!
            case .Semibold:
                return UIFont(name: "Poppins-SemiBold", size: size)!
            case .SemiboldItalic:
                return UIFont(name: "Poppins-SemiBoldItalic", size: size)!
            case .Medium:
                return UIFont(name: "Poppins-Medium", size: size)!
            
        }
    }
}

enum AppInfo
{
    case AppTitle, DeviceId, Platform, GoogleClientID, GCMSenderId, GOOGLE_MAP_API_KEY
    
    func returnAppInfo() -> String {
        switch self {
            case .AppTitle:
                return "Food Flocker"
            case .DeviceId:
                return (UIDevice.current.identifierForVendor?.uuidString)!
            case .Platform:
                return "Ios"
            case .GoogleClientID:
                return "743414197440-gtnmdv9tr2v8stqef9grqaskuo316ank.apps.googleusercontent.com"
            case .GCMSenderId:
                return "743414197440"
            case .GOOGLE_MAP_API_KEY:
                return "AIzaSyAhKfBsVwVPEtJiOYdXC0DjR_Cy5y71yFs"
        }
    }
}
