//
//  Extensions.swift
//

import Foundation
import UIKit
import MBProgressHUD
import SDWebImage

// MARK: - String (Validation)
extension String {
    var trimmedString: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    
    var isValidUserName: Bool {
        let regex = "^[A-Za-z0-9._-]{3,25}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var isStrongPassword: Bool {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*()_+=-]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var isNumber: Bool {
        let regex = "^\\+?[0-9]+$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var isValidBattleId: Bool {
        let regex = "^[0-9]+(-[0-9]+)*$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var isValidCharacter: Bool {
        let regex = "^[a-zA-Z]+$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var youTubeID: String? {
        let patterns = [
            #"(?<=v=)[^&?#]+"#,
            #"(?<=be/)[^&?#]+"#,
            #"(?<=embed/)[^&?#]+"#
        ]
        for p in patterns {
            if let r = range(of: p, options: .regularExpression) {
                let id = String(self[r])
                return id.count == 11 ? id : id
            }
        }
        return nil
    }
}

// MARK: - String (Formatting)
extension String {
    
    /// Converts HTML string to attributed string (strips CSS if needed)
    var htmlToAttributedString: NSAttributedString {
        guard let data = data(using: .utf8) else { return NSAttributedString(string: self) }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return (try? NSAttributedString(data: data, options: options, documentAttributes: nil))
            ?? NSAttributedString(string: self)
    }
    
    /// Capitalizes only the first character of the string
    var capitalizingFirstCharacter: String {
        guard let first = first else { return self }
        return String(first).uppercased() + dropFirst()
    }
    
    /// Groups characters every `n` with a given separator.
    /// Example: "12345678".grouping(every: 4, with: "-") -> "1234-5678"
    func grouping(every n: Int, with separator: Character) -> String {
        let clean = filter { $0 != separator }
        return clean.enumerated().map { idx, ch in
            (idx > 0 && idx % n == 0) ? "\(separator)\(ch)" : "\(ch)"
        }.joined()
    }
}


// MARK: - String (Attributed Helpers)
extension String {
    
    /// Core helper for attributed styling
    private func styledAttributedString(
        targets: [String],
        font: UIFont,
        extraAttributes: [NSAttributedString.Key: Any] = [:]
    ) -> NSAttributedString {
        
        let attributed = NSMutableAttributedString(
            string: self,
            attributes: [.font: Fonts.Regular.returnFont(size: font.pointSize)]
        )
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font].merging(extraAttributes) { $1 }
        
        for word in targets {
            let range = (self as NSString).range(of: word)
            if range.location != NSNotFound {
                attributed.addAttributes(attributes, range: range)
            }
        }
        return attributed
    }
    
    // MARK: - Your existing funcs (wrappers)
    
    func setAttributedString(boldString: String, fontSize: CGFloat) -> NSAttributedString {
        styledAttributedString(targets: [boldString],
                               font: Fonts.Bold.returnFont(size: fontSize))
    }
    
    func setSemiboldString(semiboldString: String, fontSize: CGFloat) -> NSAttributedString {
        styledAttributedString(targets: [semiboldString],
                               font: Fonts.Semibold.returnFont(size: fontSize))
    }
    
    func setRegularString(string: String, fontSize: CGFloat) -> NSAttributedString {
        styledAttributedString(targets: [string],
                               font: Fonts.Regular.returnFont(size: fontSize))
    }
    
    func setMultiBoldString(boldString: [String], fontSize: CGFloat) -> NSAttributedString {
        styledAttributedString(targets: boldString,
                               font: Fonts.Semibold.returnFont(size: fontSize))
    }
    
    func setMultiBoldUnderlineString(boldString: [String], fontSize: CGFloat) -> NSAttributedString {
        styledAttributedString(targets: boldString,
                               font: Fonts.Bold.returnFont(size: fontSize),
                               extraAttributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    
    func setMultiBoldColorString(boldString: [String], color: [UIColor], fontSize: CGFloat) -> NSAttributedString {
        let attributed = NSMutableAttributedString(
            string: self,
            attributes: [.font: Fonts.Regular.returnFont(size: fontSize)]
        )
        
        for (i, word) in boldString.enumerated() {
            let range = (self as NSString).range(of: word)
            if range.location != NSNotFound {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: Fonts.Bold.returnFont(size: fontSize),
                    .foregroundColor: i < color.count ? color[i] : UIColor.label
                ]
                attributed.addAttributes(attributes, range: range)
            }
        }
        return attributed
    }
}


// MARK: - UIView (HUD, Borders, Shadows)
extension UIView {
    
    // MARK: HUD
    func showLoading(tag: Int = 999_999) {
        DispatchQueue.main.async {
            if self.viewWithTag(tag) != nil { return } // prevent duplicates
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.tag = tag
        }
    }

    func hideLoading(tag: Int = 999_999) {
        DispatchQueue.main.async {
            if let hud = self.viewWithTag(tag) as? MBProgressHUD {
                hud.hide(animated: true)
            } else {
                MBProgressHUD.hide(for: self, animated: true)
            }
        }
    }
    
    // MARK: Borders
    func addDashedBorder(cornerRadius: CGFloat = 5,
                         lineDashPattern: [NSNumber] = [6, 3],
                         strokeColor: UIColor = UIColor(white: 0.137, alpha: 0.15)) {
        let key = "dashedBorderLayer"
        layer.sublayers?.removeAll(where: { $0.name == key })

        let shape = CAShapeLayer()
        shape.name = key
        shape.frame = bounds
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = strokeColor.cgColor
        shape.lineWidth = 1
        shape.lineDashPattern = lineDashPattern
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.addSublayer(shape)
    }
    
    // MARK: Corners
    func roundCorners(radius: CGFloat,
                      arrCornersiOS11: CACornerMask,
                      arrCornersBelowiOS11: UIRectCorner) {
        if #available(iOS 11.0, *) {
            clipsToBounds = false
            layer.cornerRadius = radius
            layer.maskedCorners = arrCornersiOS11
        } else {
            let rectShape = CAShapeLayer()
            rectShape.bounds = frame
            rectShape.position = center
            rectShape.path = UIBezierPath(roundedRect: bounds,
                                          byRoundingCorners: arrCornersBelowiOS11,
                                          cornerRadii: CGSize(width: radius, height: radius)).cgPath
            layer.mask = rectShape
        }
    }
    
    // MARK: Shadows
    func cornerWithShadow(offset: CGSize,
                          color: UIColor,
                          radius: CGFloat,
                          opacity: Float,
                          corner: CGFloat) {
        layer.masksToBounds = false
        layer.cornerRadius = corner
        layer.shadowColor = color.cgColor
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                        cornerRadius: layer.cornerRadius).cgPath
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
    
    /// Private shadow helper
    private func applyShadow(toEdges edges: UIRectEdge,
                             color: UIColor,
                             opacity: Float,
                             radius: CGFloat) {
        layer.masksToBounds = false
        layer.shadowOffset = .zero
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
        
        var rect = bounds
        if !edges.contains(.top)    { rect.origin.y += radius + 1 }
        if !edges.contains(.left)   { rect.origin.x += radius + 1 }
        if !edges.contains(.bottom) { rect.size.height -= radius + 1 }
        if !edges.contains(.right)  { rect.size.width -= radius + 1 }
        
        let path = UIBezierPath()
        path.move(to: rect.origin)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.close()
        
        layer.shadowPath = path.cgPath
    }
    
    // MARK: Wrappers (keep old names)
    
    /// Modern, flexible version (default = all edges)
    func addShadow(toEdges edges: UIRectEdge = [.all],
                   color: UIColor = .black,
                   opacity: Float = 0.2,
                   radius: CGFloat = 4) {
        applyShadow(toEdges: edges, color: color, opacity: opacity, radius: radius)
    }
    
    /// Legacy version (kept for backward compatibility)
    func addshadowToView(top: Bool,
                         left: Bool,
                         bottom: Bool,
                         right: Bool,
                         shadowRadius: CGFloat) {
        var edges: UIRectEdge = []
        if top    { edges.insert(.top) }
        if left   { edges.insert(.left) }
        if bottom { edges.insert(.bottom) }
        if right  { edges.insert(.right) }
        
        // Preserved legacy defaults
        applyShadow(toEdges: edges,
                    color: Colors.border.returnColor(),
                    opacity: 0.9,
                    radius: shadowRadius)
    }
}

// MARK: - UINavigationController
extension UINavigationController {
    func applyStandardAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.barTintColor = .white
            navigationBar.isTranslucent = false
            navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        }
    }
}

// MARK: - UINavigationItem
extension UINavigationItem {
    
    /// Configure navigation bar title and back button visibility
    func configureTopBar(title: String? = nil, hideBackButton: Bool = true, hideTitle: Bool = false) {
        if hideTitle {
            self.title = ""
        } else {
            self.title = title
        }
        setHidesBackButton(hideBackButton, animated: false)
    }
    
    /// Just hide the back button
    func hideBackButton() {
        setHidesBackButton(true, animated: false)
    }
}


// MARK: - RetryInternetPresentable
protocol RetryInternetPresentable: UIViewController {
    var onTappedRetry: (() -> Void)? { get set }
    static func makeInstance() -> Self
}
// MARK: - UIViewController
extension UIViewController {
    
    // MARK: Loading HUD
    func showLoading(tag: Int = 888_888) {
        DispatchQueue.main.async {
            if self.view.viewWithTag(tag) != nil { return } // prevent duplicates
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.tag = tag
        }
    }
    
    func hideLoading(tag: Int = 888_888) {
        DispatchQueue.main.async {
            if let hud = self.view.viewWithTag(tag) as? MBProgressHUD {
                hud.hide(animated: true)
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    // MARK: Internet Retry
    func isRetryInternet<T: RetryInternetPresentable>(
        retryVC: T.Type,
        completion: @escaping (_ isRetry: Bool) -> Void
    ) {
        DispatchQueue.main.async {
            let vc = T.makeInstance()   // ✅ factory method
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.onTappedRetry = { completion(true) }
            
            if self.presentedViewController == nil {
                self.present(vc, animated: true)
            }
        }
    }
    
//    1. Code-based VC
//    final class RetryVC: UIViewController, RetryInternetPresentable {
//        var onTappedRetry: (() -> Void)?
//        
//        static func makeInstance() -> Self {
//            return Self.init()
//        }
//        
//        override func viewDidLoad() {
//            super.viewDidLoad()
//            view.backgroundColor = .black.withAlphaComponent(0.5)
//            
//            let button = UIButton(type: .system)
//            button.setTitle("Retry", for: .normal)
//            button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
//            button.frame = CGRect(x: 100, y: 200, width: 120, height: 50)
//            view.addSubview(button)
//        }
//        
//        @objc private func retryTapped() {
//            dismiss(animated: true) { self.onTappedRetry?() }
//        }
//    }

//    2. Storyboard-based VC
//    final class RetryStoryboardVC: UIViewController, RetryInternetPresentable {
//        var onTappedRetry: (() -> Void)?
//
//        static func makeInstance() -> Self {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            guard let vc = storyboard.instantiateViewController(withIdentifier: "RetryStoryboardVC") as? Self else {
//                fatalError("⚠️ RetryStoryboardVC not found in storyboard")
//            }
//            return vc
//        }
//
//        @IBAction func retryTapped(_ sender: UIButton) {
//            dismiss(animated: true) { self.onTappedRetry?() }
//        }
//    }

//    // Code-based
//    isRetryInternet(retryVC: RetryVC.self) { retry in
//        if retry { print("🔄 Retry tapped") }
//    }

//    // Storyboard-based
//    isRetryInternet(retryVC: RetryStoryboardVC.self) { retry in
//        if retry { print("🔄 Retry tapped from storyboard VC") }
//    }
}


// MARK: - UITableView
extension UITableView {
    
    func updateHeaderViewHeight() {
        guard let header = tableHeaderView else { return }
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        let height = header.systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        
        if header.frame.height != height {
            header.frame.size.height = height
            tableHeaderView = header
        }
    }
    
    func updateFooterViewHeight() {
        guard let footer = tableFooterView else { return }
        footer.setNeedsLayout()
        footer.layoutIfNeeded()
        
        let height = footer.systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        
        if footer.frame.height != height {
            footer.frame.size.height = height
            tableFooterView = footer
        }
    }
    
//    // Usage
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        tableView.updateHeaderViewHeight()
//        tableView.updateFooterViewHeight()
//    }
}


// MARK: - UIImageView
extension UIImageView {
    
    /// Loads an image from a URL string with optional placeholder.
    func setImage(urlString: String?,
                  placeholder: String? = nil,
                  completion: ((UIImage?) -> Void)? = nil) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            self.image = placeholder.flatMap { UIImage(named: $0) }
            completion?(self.image)
            return
        }
        
        let placeholderImage = placeholder.flatMap { UIImage(named: $0) }
        sd_setImage(with: url, placeholderImage: placeholderImage) { image, _, _, _ in
            completion?(image)
        }
    }
    
    /// Tints the current image (works best with template images).
    func setImageColor(_ color: UIColor) {
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }
    
    /// Loads an image with optional resize, rounded mask, border, fade-in, content mode,
    /// background color while loading, caching, and completion callback.
    func setImageRounded(
        urlString: String?,
        placeholder: String? = nil,
        cornerRadius: CGFloat? = nil,
        makeCircular: Bool = false,
        fadeDuration: TimeInterval = 0.25,
        borderColor: UIColor? = nil,
        borderWidth: CGFloat = 0,
        contentMode: UIView.ContentMode = .scaleAspectFill,
        backgroundColor: UIColor? = nil,
        clearBackgroundOnLoad: Bool = false,
        targetSize: CGSize? = nil,   // 👈 Resize support
        completion: ((UIImage?) -> Void)? = nil
    ) {
        let placeholderImage = placeholder.flatMap { UIImage(named: $0) }
        
        // Apply content mode to UIImageView
        self.contentMode = contentMode
        
        // Apply background color while loading
        if let bgColor = backgroundColor {
            self.backgroundColor = bgColor
        }
        
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            self.image = placeholderImage
            applyShape(cornerRadius: cornerRadius, makeCircular: makeCircular,
                       borderColor: borderColor, borderWidth: borderWidth)
            completion?(self.image)
            return
        }
        
        // Reset shape
        layer.cornerRadius = 0
        layer.masksToBounds = false
        clipsToBounds = false
        
        // 👇 Map UIView.ContentMode → SDImageScaleMode for resizing
        var transformer: SDImageTransformer? = nil
        if let size = targetSize {
            let scaleMode: SDImageScaleMode
            switch contentMode {
            case .scaleAspectFit: scaleMode = .aspectFit
            case .scaleToFill:    scaleMode = .fill
            default:              scaleMode = .aspectFill
            }
            transformer = SDImageResizingTransformer(size: size, scaleMode: scaleMode)
        }
        
        sd_setImage(
            with: url,
            placeholderImage: placeholderImage,
            context: transformer != nil ? [.imageTransformer: transformer!] : nil
        ) { [weak self] image, _, _, _ in
            guard let self = self else { return }
            
            if let img = image {
                // Fade in animation
                self.alpha = 0
                UIView.animate(withDuration: fadeDuration) {
                    self.alpha = 1
                }
                
                self.image = img
                
                // Clear background if requested
                if clearBackgroundOnLoad {
                    self.backgroundColor = .clear
                }
                
                // Apply shape + border
                self.applyShape(cornerRadius: cornerRadius, makeCircular: makeCircular,
                                borderColor: borderColor, borderWidth: borderWidth)
            }
            
            completion?(image)
        }
    }
    
    // MARK: - Private Helpers
    private func applyShape(
        cornerRadius: CGFloat?,
        makeCircular: Bool,
        borderColor: UIColor?,
        borderWidth: CGFloat
    ) {
        if makeCircular {
            layer.cornerRadius = bounds.width / 2
            clipsToBounds = true
        } else if let radius = cornerRadius {
            layer.cornerRadius = radius
            clipsToBounds = true
        } else {
            clipsToBounds = false
        }
        
        if let color = borderColor, borderWidth > 0 {
            layer.borderColor = color.cgColor
            layer.borderWidth = borderWidth
        } else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }
    }
    
    // Usage
//    // ✅ Circle avatar (auto-clear background after load, resized to 100x100)
//    avatarImageView.setImageRounded(
//        urlString: user.profilePic,
//        placeholder: "UserPlaceholder",
//        makeCircular: true,
//        borderColor: .white,
//        borderWidth: 2,
//        backgroundColor: .lightGray,
//        clearBackgroundOnLoad: true,
//        targetSize: CGSize(width: 100, height: 100)   // 👈 Thumbnail size
//    )
//
//    // ✅ Banner with rounded corners (cached & resized to screen width)
//    bannerImageView.setImageRounded(
//        urlString: "https://example.com/banner.jpg",
//        cornerRadius: 12,
//        fadeDuration: 0.3,
//        targetSize: CGSize(width: UIScreen.main.bounds.width, height: 200)
//    )
//
//    // ✅ Plain icon, keep background
//    iconImageView.setImageRounded(
//        urlString: "https://example.com/icon.png",
//        contentMode: .center,
//        backgroundColor: .systemGray5,
//        clearBackgroundOnLoad: false
//    )

}


    // MARK: - UILabel (Icon Helpers)
    extension UILabel {
        enum IconPosition {
            case left
            case right
        }
        
        /// Sets label text with an icon (system or asset), positioned left or right. Supports multi-line text.
        func setIconText(
            _ title: String,
            iconName: String,
            isSystemIcon: Bool = true,
            iconPosition: IconPosition = .left,
            iconTint: UIColor? = nil,
            iconSize: CGSize? = nil,       // fixed size if provided
            padding: CGFloat = 4,          // spacing between icon & text
            alignToFont: Bool = true       // ensures alignment with text line
        ) {
            let ms = NSMutableAttributedString()
            
            var img: UIImage?
            img = isSystemIcon ? UIImage(systemName: iconName) : UIImage(named: iconName)
            
            if let img = img {
                let att = AlignedTextAttachment()
                
                // Resize if needed
                let finalSize: CGSize
                if let size = iconSize {
                    finalSize = size
                } else {
                    let ratio = font.lineHeight / img.size.height
                    finalSize = CGSize(width: img.size.width * ratio, height: img.size.height * ratio)
                }
                
                UIGraphicsBeginImageContextWithOptions(finalSize, false, 0.0)
                img.draw(in: CGRect(origin: .zero, size: finalSize))
                let resized = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                att.image = iconTint != nil ? resized?.withRenderingMode(.alwaysTemplate) : resized
                att.bounds = CGRect(x: 0, y: 0, width: finalSize.width, height: finalSize.height)
                
                // Adjust vertical alignment
                if alignToFont {
                    att.yOffset = (font.capHeight - finalSize.height).rounded() / 2
                }
                
                let iconAttr = NSAttributedString(attachment: att)
                let textAttr: [NSAttributedString.Key: Any] = [
                    .font: font as Any,
                    .foregroundColor: textColor ?? .label
                ]
                let textString = NSAttributedString(string: title, attributes: textAttr)
                
                if iconPosition == .left {
                    ms.append(iconAttr)
                    ms.append(NSAttributedString(string: String(repeating: " ", count: Int(padding/2))))
                    ms.append(textString)
                } else {
                    ms.append(textString)
                    ms.append(NSAttributedString(string: String(repeating: " ", count: Int(padding/2))))
                    ms.append(iconAttr)
                }
            } else {
                ms.append(NSAttributedString(string: title))
            }
            
            attributedText = ms
            numberOfLines = 0 // 👈 allow multi-line wrapping
            lineBreakMode = .byWordWrapping
            
            if let tint = iconTint { tintColor = tint }
        }
    }


// MARK: - NSLayoutConstraint
extension NSLayoutConstraint {
    func withMultiplier(_ m: CGFloat) -> NSLayoutConstraint {
        guard let firstItem = firstItem else { return self }
        NSLayoutConstraint.deactivate([self])
        let new = NSLayoutConstraint(item: firstItem, attribute: firstAttribute,
                                     relatedBy: relation, toItem: secondItem,
                                     attribute: secondAttribute, multiplier: m, constant: constant)
        new.priority = priority
        new.identifier = identifier
        NSLayoutConstraint.activate([new])
        return new
    }
}

// MARK: - TimeZone (Offset Helpers)
extension TimeZone {
    
    /// Numeric offset in hours/minutes from GMT (e.g. `+05:30`, `-04:00`)
    var offsetString: String {
        let seconds = secondsFromGMT()
        let hours = seconds / 3600
        let minutes = abs(seconds / 60) % 60
        return String(format: "%+.2d:%02d", hours, minutes)
    }
    
    /// Offset without colon (e.g. `+0530`, `-0400`)
    var compactOffsetString: String {
        return offsetString.replacingOccurrences(of: ":", with: "")
    }
    
    /// GMT style string (e.g. `GMT+05:30`, `GMT-04:00`)
    var gmtOffsetString: String {
        return "GMT" + offsetString
    }
    
    /// Abbreviation + offset (e.g. `IST (+05:30)`, `EST (-04:00)`)
    var abbreviationWithOffset: String {
        let abbr = abbreviation() ?? identifier
        return "\(abbr) (\(offsetString))"
    }
    
    /// Full localized name with offset (e.g. `India Standard Time (+05:30)`)
    var localizedNameWithOffset: String {
        let name = localizedName(for: .standard, locale: .current) ?? identifier
        return "\(name) (\(offsetString))"
    }
    
//    let tz = TimeZone.current
//
//    print(tz.offsetString)           // "+05:30"
//    print(tz.compactOffsetString)    // "+0530"
//    print(tz.gmtOffsetString)        // "GMT+05:30"
//    print(tz.abbreviationWithOffset) // "IST (+05:30)"
//    print(tz.localizedNameWithOffset)// "India Standard Time (+05:30)"

}


// MARK: - UIColor (Hex Support)
extension UIColor {
    
    /// Initialize UIColor with hex string (#RGB, #RRGGBB, or #RRGGBBAA)
    convenience init?(hexString: String) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") { hex.removeFirst() }
        
        // Expand shorthand #RGB → #RRGGBB
        if hex.count == 3 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }
        
        // #RRGGBBAA
        if hex.count == 8, let int = UInt32(hex, radix: 16) {
            let r = CGFloat((int >> 24) & 0xFF) / 255
            let g = CGFloat((int >> 16) & 0xFF) / 255
            let b = CGFloat((int >> 8) & 0xFF) / 255
            let a = CGFloat(int & 0xFF) / 255
            self.init(red: r, green: g, blue: b, alpha: a)
            return
        }
        
        // #RRGGBB
        if hex.count == 6, let int = UInt32(hex, radix: 16) {
            let r = CGFloat((int >> 16) & 0xFF) / 255
            let g = CGFloat((int >> 8) & 0xFF) / 255
            let b = CGFloat(int & 0xFF) / 255
            self.init(red: r, green: g, blue: b, alpha: 1.0)
            return
        }
        
        return nil
    }
    
    /// Convert UIColor to hex string (#RRGGBB or #RRGGBBAA if alpha < 1)
    func toHexString(includeAlpha: Bool = false) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        if includeAlpha {
            let rgba: Int = (Int(r*255)<<24) | (Int(g*255)<<16) | (Int(b*255)<<8) | Int(a*255)
            return String(format: "#%08X", rgba)
        } else {
            let rgb: Int = (Int(r*255)<<16) | (Int(g*255)<<8) | Int(b*255)
            return String(format: "#%06X", rgb)
        }
    }
    
    // Usage
//    #RGB
//    #RRGGBB
//    #RRGGBBAA
//    // Init
//    let red1 = UIColor(hexString: "#FF0000")
//    let red2 = UIColor(hexString: "F00")        // shorthand
//    let blueWithAlpha = UIColor(hexString: "#0000FF80") // semi-transparent blue
//
//    // To hex
//    UIColor.red.toHexString()              // "#FF0000"
//    UIColor.red.toHexString(includeAlpha: true) // "#FF0000FF"
//    blueWithAlpha?.toHexString(includeAlpha: true) // "#0000FF80"

}


public extension UIDevice {
    static let modelIdentifier: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }()
    
    /// Human-readable device name (e.g. "iPhone 13 Pro")
    static let modelName: String = {
        let id = modelIdentifier
        
        switch id {
            // MARK: iPod
        case "iPod5,1": return "iPod touch (5th gen)"
        case "iPod7,1": return "iPod touch (6th gen)"
        case "iPod9,1": return "iPod touch (7th gen)"
            
            // MARK: iPhone
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE (1st gen)"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone12,8": return "iPhone SE (2nd gen)"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,6": return "iPhone SE (3rd gen)"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone16,1": return "iPhone 15"
        case "iPhone16,2": return "iPhone 15 Plus"
        case "iPhone16,3": return "iPhone 15 Pro"
        case "iPhone16,4": return "iPhone 15 Pro Max"
            
            // MARK: iPad
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad (3rd gen)"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad (4th gen)"
        case "iPad6,11", "iPad6,12": return "iPad (5th gen)"
        case "iPad7,5", "iPad7,6": return "iPad (6th gen)"
        case "iPad7,11", "iPad7,12": return "iPad (7th gen)"
        case "iPad11,6", "iPad11,7": return "iPad (8th gen)"
        case "iPad12,1", "iPad12,2": return "iPad (9th gen)"
        case "iPad13,18", "iPad13,19": return "iPad (10th gen)"
            
            // MARK: iPad Mini
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad mini 3"
        case "iPad5,1", "iPad5,2": return "iPad mini 4"
        case "iPad11,1", "iPad11,2": return "iPad mini (5th gen)"
        case "iPad14,1", "iPad14,2": return "iPad mini (6th gen)"
            
            // MARK: iPad Air
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad11,3", "iPad11,4": return "iPad Air (3rd gen)"
        case "iPad13,1", "iPad13,2": return "iPad Air (4th gen)"
        case "iPad13,16", "iPad13,17": return "iPad Air (5th gen)"
            
            // MARK: iPad Pro
        case "iPad6,3", "iPad6,4": return "iPad Pro (9.7-inch)"
        case "iPad7,3", "iPad7,4": return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch, 1st gen)"
        case "iPad8,9", "iPad8,10": return "iPad Pro (11-inch, 2nd gen)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "iPad Pro (11-inch, 3rd gen)"
        case "iPad14,3", "iPad14,4": return "iPad Pro (11-inch, 4th gen)"
        case "iPad6,7", "iPad6,8": return "iPad Pro (12.9-inch, 1st gen)"
        case "iPad7,1", "iPad7,2": return "iPad Pro (12.9-inch, 2nd gen)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro (12.9-inch, 3rd gen)"
        case "iPad8,11", "iPad8,12": return "iPad Pro (12.9-inch, 4th gen)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro (12.9-inch, 5th gen)"
        case "iPad14,5", "iPad14,6": return "iPad Pro (12.9-inch, 6th gen)"
            
            // MARK: Apple TV
        case "AppleTV5,3": return "Apple TV HD"
        case "AppleTV6,2": return "Apple TV 4K (1st gen)"
        case "AppleTV11,1": return "Apple TV 4K (2nd gen)"
        case "AppleTV14,1": return "Apple TV 4K (3rd gen)"
            
            // MARK: HomePod
        case "AudioAccessory1,1": return "HomePod"
        case "AudioAccessory5,1": return "HomePod mini"
            
            // MARK: Simulator
        case "i386", "x86_64", "arm64":
            return "Simulator (\(ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            
            // MARK: Default
        default: return id
        }
    }()
}


// MARK: - Array (Unique Helpers)
extension Array where Element: Equatable {
    func unique() -> [Element] {
        var result = [Element]()
        for value in self where !result.contains(value) {
            result.append(value)
        }
        return result
    }
}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
