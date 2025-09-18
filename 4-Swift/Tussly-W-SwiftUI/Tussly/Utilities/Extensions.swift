//
//  Extensions.swift
//  - Contains additional requried methods for existing predefined classes.

//  Tussly
//
//  Created by Jaimesh Patel on 05/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import CometChatSDK


extension String {
    var trimmedString: String { return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
    
    //Username Validation
    func isValidUserName(string: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[^a-zA-Z0-9]{1,25}", options: .caseInsensitive)
            if regex.matches(in: string, options: [], range: NSMakeRange(0, string.count)).count > 0 {
                return false
            }
        }catch {
            
        }
        return true
    }
    
    //Phone No Validation
    func isValidPassword() -> Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    var isNumber: Bool {
        return !isEmpty && range(of: "[^0-9+]", options: .regularExpression) == nil
    }
    
    var isBattleId: Bool {
        let regex = ".*[^-0-9].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
    
    //Email Validation
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    //Character Validation
    func isValidCharecter() -> Bool {
        let regularExpression = "^[a-zA-Z]+$"
        let passwordValidation = NSPredicate(format: "SELF MATCHES %@", regularExpression)
        
        return passwordValidation.evaluate(with: self)
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .unicode) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func grouping(every groupSize: String.IndexDistance, with separator: Character) -> String {
        let cleanedUpCopy = replacingOccurrences(of: String(separator), with: "")
        return String(cleanedUpCopy.enumerated().map() {
            $0.offset % groupSize == 0 ? [separator, $0.element] : [$0.element]
        }.joined().dropFirst())
    }
    
    func getYoutubeVideoId(url:String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)", options: NSRegularExpression.Options.caseInsensitive)
            let match = regex.firstMatch(in: url, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, url.lengthOfBytes(using: String.Encoding.utf8)))
            if match != nil {
                let range = match?.range(at: 0)
                let youTubeID = (url as NSString).substring(with: range!)
                return youTubeID
            } else {
                return ""
            }
        } catch {
            return ""
        }
    }
    
    func setAttributedString(boldString: String, fontSize: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self,
                                                         attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: fontSize)])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.Bold.returnFont(size: fontSize)]
        let range = (self as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    func setSemiboldString(semiboldString: String, fontSize: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self,
                                                         attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: fontSize)])
        let semiboldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.Semibold.returnFont(size: fontSize)]
        let range = (self as NSString).range(of: semiboldString)
        attributedString.addAttributes(semiboldFontAttribute, range: range)
        return attributedString
    }
    
    func setRegularString(string: String, fontSize: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self,
                                                         attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0)])
        let semiboldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: fontSize)]
        let range = (self as NSString).range(of: string)
        attributedString.addAttributes(semiboldFontAttribute, range: range)
        return attributedString
    }
    
    func setMultiBoldString(boldString: [String], fontSize: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self,
                                                         attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: fontSize)])
        let semiboldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.Semibold.returnFont(size: fontSize)]
        for i in 0 ..< boldString.count {
            let range = (self as NSString).range(of: boldString[i])
            attributedString.addAttributes(semiboldFontAttribute, range: range)
        }
        return attributedString
    }
    
    func setMultiBoldUnderlineString(boldString: [String], fontSize: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self,
                                                         attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: fontSize)])
        
        let semiboldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.Bold.returnFont(size: fontSize),
                                                                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        for i in 0 ..< boldString.count {
            let range = (self as NSString).range(of: boldString[i])
            attributedString.addAttributes(semiboldFontAttribute, range: range)
        }
        return attributedString
    }
    
    func setMultiBoldColorString(boldString: [String], color: [UIColor], fontSize: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self,
                                                         attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: fontSize)])
        
        for i in 0 ..< boldString.count {
            let range = (self as NSString).range(of: boldString[i])
            let semiboldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.Bold.returnFont(size: fontSize),
                                                                        NSAttributedString.Key.foregroundColor: color[i]]
            attributedString.addAttributes(semiboldFontAttribute, range: range)
        }
        return attributedString
    }
}

extension UIView {
    
    func showLoading() {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self, animated: true)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self, animated: true)
        }
    }
    
    var rootNavController: UINavigationController {
        if #available(iOS 13.0, *) {
            return (self.window?.rootViewController)! as! UINavigationController
        } else {
            return (appDelegate.window?.rootViewController)! as! UINavigationController
        }
    }
    
    var tusslyTabVC: TusslyTabVC {
        if #available(iOS 13.0, *) {
            
            guard let navController = self.window?.rootViewController as? UINavigationController else {
                //return
                let tusslyTabVC = TusslyTabVC()
                // Wrap TusslyTabVC in a UINavigationController
                let navigationController = UINavigationController(rootViewController: tusslyTabVC)
                return navigationController.topViewController as! TusslyTabVC
            }
            return navController.topViewController as! TusslyTabVC
        }
        else {
            let navController = appDelegate.window?.rootViewController as! UINavigationController
            return navController.topViewController as! TusslyTabVC
        }
    }
    
    func addDashedBorder() {
        let color = UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 0.15).cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
    
    func roundCorners(radius: CGFloat, arrCornersiOS11: CACornerMask, arrCornersBelowiOS11: UIRectCorner) {
        
        if #available(iOS 11.0, *){
            self.clipsToBounds = false
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = arrCornersiOS11
        } else {
            let rectShape = CAShapeLayer()
            rectShape.bounds = self.frame
            rectShape.position = self.center
            rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: arrCornersBelowiOS11, cornerRadii: CGSize(width: radius, height: radius)).cgPath
            self.layer.mask = rectShape
        }
    }
    
    func cornerWithShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float, corner: CGFloat) {
        layer.masksToBounds = false
        layer.cornerRadius = corner
        layer.shadowColor = color.cgColor
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
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
    
    func addshadowToView(top: Bool,
                         left: Bool,
                         bottom: Bool,
                         right: Bool,
                         shadowRadius: CGFloat) {
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 0.9
        self.layer.shadowColor = Colors.border.returnColor().cgColor
        
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        /*
         |☐
         */
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        /*
         ☐
         -
         */
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        /*
         ☐|
         */
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        /*
         _
         ☐
         */
        path.close()
        self.layer.shadowPath = path.cgPath
    }
    
    func roundCornersWithShadow(
        cornerRadius: CGFloat = 8.0,
        shadowColor: UIColor = .black,
        shadowOffset: CGSize = CGSize(width: 0, height: 2),
        shadowOpacity: Float = 0.2,
        shadowRadius: CGFloat = 4.0,
        borderWidth: CGFloat = 0,
        borderColor: UIColor = .black
    ) {
        // Round corners
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        
        // Shadow
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        
        // Border
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
}

extension UINavigationController {
    func updateNavigation(width: CGFloat) {
        self.isNavigationBarHidden = false
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(descriptor: UIFontDescriptor(name: "OpenSans-Bold", size: 20), size: 20)]
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.frame = CGRect(x: 0, y: 0, width: 300, height: 50.0)
    }
}

extension UINavigationItem {
    func setTopbar() {
        self.title = "Arena"
        self.setHidesBackButton(true, animated: false)
    }
    /// By Pranay
    func hideBackBtn() {
        self.setHidesBackButton(true, animated: false)
    }
    /// .
}

extension UIViewController {
    
    func openGroupChat(id: String) {
    }
    
    // - 1111 - For Arena
    func openArenaGroupConvorsation(id: String, type: CometChat.ConversationType, isFromArena: Bool = false, tusslyTabVC: (()->TusslyTabVC)?, completion: @escaping (Bool) -> Void) {
        CometChat.getConversation(conversationWith: id, conversationType: type) { conversation in
          print("success \(String(describing: conversation?.stringValue()))")
            self.openArenaConvorsation(conversation: conversation!, type: type, isFromArena: isFromArena, tusslyTabVC: tusslyTabVC) {
                success in
                completion(true)
            }
        } onError: { error in
          print("error \(String(describing: error?.errorDescription))")
            Utilities.showPopup(title: "\((error?.errorDescription)!)", type: .error)
            completion(false)
        }
    }
    
    fileprivate func openArenaConvorsation(conversation: Conversation, type: CometChat.ConversationType, isFromArena: Bool, tusslyTabVC: (()->TusslyTabVC)?, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            let messagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatMessageVC") as! ChatMessageVC
            
            messagesVC.isFromArena = isFromArena
            messagesVC.tusslyTabVC = tusslyTabVC
            
            messagesVC.objConversation = conversation
            messagesVC.user = conversation.conversationWith as? CometChatSDK.User
            messagesVC.senderId = APIManager.sharedManager.strChatUserId
            messagesVC.isGroup = false
            messagesVC.receiverId = (conversation.conversationWith as? CometChatSDK.User)?.uid ?? ""
            messagesVC.conversationId = conversation.conversationId ?? ""
            
            if let group = conversation.conversationWith as? CometChatSDK.Group {
                messagesVC.group = group
                messagesVC.isGroup = true
                messagesVC.receiverId = group.guid
            }
            
            completion(true)
            
            self.navigationController?.pushViewController(messagesVC, animated: true)
        }
    }
    /// - 1111 - */
    
    func getUnreadChatCount(id: Int) -> NSNumber {
        return 0
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func isRetryInternet(completion: @escaping (_ isRetry: Bool?) -> Void) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "NoInternetConnectionVC") as! NoInternetConnectionVC
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        objVC.onTappedRetry = {
            completion(true)
        }
        self.present(objVC, animated: true, completion: nil)
    }
}

extension UITableView {
    func updateHeaderViewHeight() {
        if let header = self.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(CGSize(width: self.bounds.width, height: 0))
            header.frame.size.height = newSize.height
        }
    }
}

extension UIImageView {
    func setImage(imageUrl : String, placeHolder: String? = "Default") {
        self.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: placeHolder!))
    }
    
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
    
    func setCharacter(imageUrl : String, placeHolder: String? = "default_character") {
        self.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: placeHolder!))
    }
}

extension UILabel {
    func getEmptyValidationString(_ string: String) {
        self.setLeftArrow(title: "Please enter \(string)")
    }
    
    func getValidationString(_ string: String) {
        self.setLeftArrow(title: "Please enter valid \(string)")
    }
    
    func addCharacterSpacing(kernValue: Double = 5) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 18.0), range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
    
    func setLeftArrow(title: String) {
        self.textColor = Colors.theme.returnColor()//Colors.validationMsg.returnColor()
        let loginString = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        let attachment = NSTextAttachment()
        attachment.image = UIImage(imageLiteralResourceName: "Error")
        attachment.bounds = CGRect(x: 0, y: (font.capHeight - attachment.image!.size.height).rounded() / 2, width: attachment.image!.size.width, height: attachment.image!.size.height)
        var attachmentString = NSAttributedString()
        attachmentString = NSAttributedString(attachment: attachment)
        loginString.append(attachmentString)
        loginString.append(NSAttributedString(string: " \(title)"))
        self.attributedText = loginString
    }
}

extension NSLayoutConstraint {
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint.deactivate([self])
        let newConstraint = NSLayoutConstraint(
            item: firstItem ?? 0.0,
            attribute: firstAttribute,relatedBy: relation,toItem: secondItem,attribute: secondAttribute,multiplier: multiplier,
            constant: constant)
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

// By Pranay
extension TimeZone {
    func offsetFromGMT() -> String
    {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.timeZone = self
        localTimeZoneFormatter.dateFormat = "Z"
        //print(localTimeZoneFormatter.string(from: Date()))
        //let str1 = (localTimeZoneFormatter.string(from: Date())).unfoldSubSequences(limitedTo: 3).joined(separator: ":")
        return (localTimeZoneFormatter.string(from: Date())).unfoldSubSequences(limitedTo: 3).joined(separator: ":")
    }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    func inserting<S: StringProtocol>(separator: S, every n: Int) -> Self {
        .init(unfoldSubSequences(limitedTo: n).joined(separator: separator))
    }
}

extension Collection {
    func unfoldSubSequences(limitedTo maxLength: Int) -> UnfoldSequence<SubSequence,Index> {
        sequence(state: startIndex) { start in
            guard start < endIndex else { return nil }
            let end = index(start, offsetBy: maxLength, limitedBy: endIndex) ?? endIndex
            defer { start = end }
            return self[start..<end]
        }
    }
}

extension NSMutableAttributedString {
    var fontSize:CGFloat { return 14 }
    var boldFont:UIFont { return UIFont(name: "OpenSans-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont(name: "OpenSans-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    
    func bold(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func blackHighlight(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}

extension String {
    func withBoldText(text: String, font: UIFont? = nil) -> NSAttributedString {
        let _font = font ?? UIFont.systemFont(ofSize: 14, weight: .regular)
        let fullString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: _font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: _font.pointSize)]
        let range = (self as NSString).range(of: text)
        fullString.addAttributes(boldFontAttribute, range: range)
        return fullString
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
//.

/// 112 - By Pranay
public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
#if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPhone14,7":                                    return "iPhone 14"
            case "iPhone14,8":                                    return "iPhone 14 Plus"
            case "iPhone15,2":                                    return "iPhone 14 Pro"
            case "iPhone15,3":                                    return "iPhone 14 Pro Max"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
#elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
#endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
}

extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
}

public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}
