//
//  Extensions.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 25/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import SwiftGifOrigin
import SDWebImage

extension String {
    var trimmedString: String { return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }

    var isNumber: Bool {
        return !isEmpty && range(of: "[^0-9+]", options: .regularExpression) == nil
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    //Email Validation
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func grouping(every groupSize: String.IndexDistance, with separator: Character) -> String {
        let cleanedUpCopy = replacingOccurrences(of: String(separator), with: "")
        return String(cleanedUpCopy.enumerated().map() {
            $0.offset % groupSize == 0 ? [separator, $0.element] : [$0.element]
            }.joined().dropFirst())
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .unicode) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
}

extension UILabel {
    func getEmptyValidationString(_ string: String) {
        
        var tmpString: String = string
        if tmpString.last! == "*" {
            tmpString.removeLast()
        }
        
        self.setLeftArrow(title: "Please enter \(tmpString)")
    }

    func getValidationString(_ string: String) {
        
        var tmpString: String = string
        if tmpString.last! == "*" {
            tmpString.removeLast()
        }
        
        self.setLeftArrow(title: "Please enter valid \(tmpString)")
    }
    
    func setLeftArrow(title: String) {
        self.font = Fonts.Regular.returnFont(size: 12.0)
        self.textColor = Colors.red.returnColor()
//        let loginString = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
//        let attachment = NSTextAttachment()
//        attachment.image = UIImage(imageLiteralResourceName: "Error")
//        var attachmentString = NSAttributedString()
//        attachmentString = NSAttributedString(attachment: attachment)
//        loginString.append(attachmentString)
//        loginString.append(NSAttributedString(string: " \(title)"))
//        self.attributedText = loginString
        self.text = title
    }
    
    func setAttributedRequiredText() {
        let attributedString = NSMutableAttributedString(string: self.text!, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 13.0)])
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: self.text!.trimmedString.count))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red.returnColor(), range: NSRange(location: self.text!.trimmedString.count - 1, length: 1))

        self.attributedText = attributedString
    }
    
    func setUnderLine(text: String) {
        
        let main_string = self.text
        let range = (main_string! as NSString).range(of: text)
        let attributedString = NSMutableAttributedString(string:main_string!)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        self.attributedText = attributedString
        
    }
    
}

extension UIViewController {
    func showLoading() {
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            
            let animatedGIF = UIImageView()
            animatedGIF.image = UIImage.gif(name: "loading")
            animatedGIF.contentMode = .scaleAspectFit
            animatedGIF.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
            hud.customView = animatedGIF
            hud.customView?.tintColor = UIColor.clear
            hud.customView?.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
            hud.mode = .customView
            hud.backgroundView.color = UIColor.black.withAlphaComponent(0.5)
            
//            hud.backgroundView.style = .blur
//            hud.backgroundView.blurEffectStyle = .
            hud.customView?.backgroundColor = UIColor.clear
            hud.bezelView.style = .solidColor
            hud.bezelView.backgroundColor = UIColor.clear
            hud.bezelView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
            
            hud.show(animated: true)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func setHomeRootViewController() {
        DispatchQueue.main.async {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "FFTabVC") as! FFTabVC
            let objNavVC = UINavigationController(rootViewController: objVC)
            objNavVC.interactivePopGestureRecognizer?.isEnabled = false
            objNavVC.navigationBar.isHidden = true
            objNavVC.popToRootViewController(animated: false)
            self.view.window?.rootViewController = objNavVC
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    // Retry for an Internet Connection
    func isRetryInternet(completion: @escaping (_ isRetry: Bool?) -> Void) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "NoInternetConnectionVC") as! NoInternetConnectionVC
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        objVC.onTappedRetry = {
            completion(true)
        }
        self.present(objVC, animated: true, completion: nil)
    }
    
    func checkForPhotos() {
        let alert = UIAlertController(title: AppInfo.AppTitle.returnAppInfo(), message: "Turn on photos services to allow \"Food Flocker\" for download ticket", preferredStyle: .alert)
        alert.view.tintColor = .black
        alert.addAction(UIAlertAction(title: "Settings", style: .default){
            UIAlertAction in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                } else {
                    
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.view.ffTabVC.present(alert, animated: true, completion: nil)
    }
}

extension UIImage {
   
    func resizeImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UIImageView {
    func setImage(imageUrl : String, placeHolder: String = "Default") {
        self.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: placeHolder))
    }
}

extension UIView {
    
    var ffTabVC: FFTabVC {
        if #available(iOS 13.0, *) {
            let navController = (self.window?.rootViewController)! as! UINavigationController
            return navController.viewControllers[0] as! FFTabVC
        } else {
            let navController = appDelegate.window?.rootViewController as! UINavigationController
            return navController.viewControllers[0] as! FFTabVC
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func roundCornersWithShadow(corners: UIRectCorner, radius: CGFloat, bgColor: UIColor, shadowHeight: Double = 6.0) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
//        layer.mask = mask
        
        mask.fillColor = bgColor.cgColor//UIColor.white.cgColor

        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowColor = Colors.gray.returnColor().cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        shadowLayer.shadowRadius = 3.0//10.0
        shadowLayer.shadowOpacity = 0.25
        shadowLayer.shadowPath = mask.path

        self.layer.insertSublayer(shadowLayer, at: 0)
        self.layer.insertSublayer(mask, at: 1)
    }
    
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    
    //Kishor
    func roundCorners(radius: CGFloat, arrCornersiOS11: CACornerMask, arrCornersBelowiOS11: UIRectCorner) {

        if #available(iOS 11.0, *){

            self.clipsToBounds = false

            self.layer.cornerRadius = radius

            self.layer.maskedCorners = arrCornersiOS11

        }else{

            let rectShape = CAShapeLayer()

            rectShape.bounds = self.frame

            rectShape.position = self.center

            rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: arrCornersBelowiOS11, cornerRadii: CGSize(width: radius, height: radius)).cgPath

            self.layer.mask = rectShape

        }

    }
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension Date {
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self)
    }
    
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy"
        return dateFormatter.string(from: self)
    }
}

extension Data {
    var format: String {
        let array = [UInt8](self)
        let ext: String
        switch (array[0]) {
        case 0xFF:
            ext = "jpg"
        case 0x89:
            ext = "png"
        case 0x47:
            ext = "gif"
        case 0x49, 0x4D :
            ext = "tiff"
        default:
            ext = "unknown"
        }
        return ext
    }
}
