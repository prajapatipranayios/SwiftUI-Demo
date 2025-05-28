//
//  FloatLabelTextView.swift
//  - Custom TextView to make its UI as per the shared design.
//
//  Created by Jaimesh Patel on 28/11/14.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

@IBDesignable class FFUIView: UITextView {
    
	let animationDuration = 0.3
	let placeholderTextColor = Colors.lightGray.returnColor()
	fileprivate var isIB = false
    fileprivate var title = UILabel()
	var hintLabel = UILabel()
	
	// MARK:- Properties
    override var tintColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var titleFont:UIFont = Fonts.Regular.returnFont(size: 16.0) {
		didSet {
			title.font = titleFont
		}
	}
	
	@IBInspectable var hint:String = "" {
		didSet {
			title.text = hint
			title.sizeToFit()
            //Jaimesh
            let r = title.frame
			hintLabel.text = hint
            hintLabel.frame = r
			hintLabel.sizeToFit()
		}
	}
	
	@IBInspectable var hintYPadding:CGFloat = 0.0 {
		didSet {
			adjustTopTextInset()
		}
	}
	
	@IBInspectable var titleYPadding:CGFloat = -4.0 { ///Jaimesh - 0
		didSet {
			var r = title.frame
			r.origin.y = titleYPadding
			title.frame = r
            
		}
	}
	
    @IBInspectable var titleTextColour:UIColor = Colors.lightGray.returnColor() {
		didSet {
			if !isFirstResponder {
				title.textColor = titleTextColour
			}
		}
	}
	
	@IBInspectable var titleActiveTextColour:UIColor! { // = UIColor.cyan
		didSet {
			if isFirstResponder {
				title.textColor = titleActiveTextColour
			}
		}
	}
    
    var imgViewHeight = 20
	
	// MARK:- Init
	required init?(coder aDecoder:NSCoder) {
		super.init(coder:aDecoder)
		setup()
	}
	
	override init(frame:CGRect, textContainer:NSTextContainer?) {
		super.init(frame:frame, textContainer:textContainer)
		setup()
	}
	
	deinit {
		if !isIB {
			let nc = NotificationCenter.default
            nc.removeObserver(self, name: UITextView.textDidChangeNotification, object:self)
            nc.removeObserver(self, name: UITextView.textDidBeginEditingNotification, object:self)
			nc.removeObserver(self, name: UITextView.textDidEndEditingNotification, object:self)
		}
	}
	
	// MARK:- Overrides
    
	override func prepareForInterfaceBuilder() {
		isIB = true
		setup()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
        
        if !isEditable {
            setTitlePositionForTextAlignment()
        }
        
		adjustTopTextInset()
		hintLabel.alpha = text.isEmpty ? 1.0 : 0.0
        
		let r = textRect()
		hintLabel.frame = CGRect(x: r.origin.x, y: r.origin.y, width: hintLabel.frame.size.width, height: hintLabel.frame.size.height)
        
        
//		setTitlePositionForTextAlignment()
        //Jaimesh
        
        //
		let isResp = isFirstResponder
		if isResp && !text.isEmpty {
			title.textColor = titleActiveTextColour
//            rightView.isHidden = false
		}
//        else {
//			title.textColor = titleActiveTextColour
//            rightView.isHidden = true
//		}
        
		// Should we show or hide the title label?
		if text.isEmpty {
			// Hide
			hideTitle(isResp)
            self.tintColor = Colors.lightGray.returnColor() //titleTextColour //Jaimesh
		} else {
			// Show
			showTitle(isResp)
            self.tintColor = Colors.gray.returnColor()//Colors.black.returnColor() //Jaimesh
		}
        self.layoutIfNeeded()
	}
	
	// MARK:- Public Methods
    
//    func setAttributedPlaceholder(_ color: UIColor) {
//        if self.hint != "" {
//            let attributedString = NSMutableAttributedString(string: self.hint, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0)])
//            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: self.hint.trimmedString.count))
//            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red.returnColor(), range: NSRange(location: self.hint.trimmedString.count - 1, length: 1))
//
//            self.attributedPlaceholder = attributedString
//            setAttributedTitle(color)
//        }
//    }

    func updateColor(_ color: UIColor) {
        if self.hint != "" {
//            let attributedString = NSMutableAttributedString(string: self.hint, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 13.0)])
//            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: self.hint.trimmedString.count))
//            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red.returnColor(), range: NSRange(location: self.hint.trimmedString.count - 1, length: 1))
//
//            self.title.attributedText = attributedString
            self.titleActiveTextColour = color
            self.title.textColor = self.titleActiveTextColour
        }
    }
    
    func setAttributedPlaceholder(_ color: UIColor) {
        if self.hintLabel.text != nil {
            let attributedString = NSMutableAttributedString(string: self.hintLabel.text!, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0)])
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: self.hintLabel.text!.trimmedString.count))
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red.returnColor(), range: NSRange(location: self.hintLabel.text!.trimmedString.count - 1, length: 1))

            self.hintLabel.attributedText = attributedString
            setAttributedTitle(color)
        }
    }

    func setAttributedTitle(_ color: UIColor) {
        if self.hintLabel.text != nil {
            let attributedString = NSMutableAttributedString(string: self.hintLabel.text!, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 13.0)])
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: self.hintLabel.text!.trimmedString.count))
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red.returnColor(), range: NSRange(location: self.hintLabel.text!.trimmedString.count - 1, length: 1))

            self.title.attributedText = attributedString
        }
    }
    
    func showTitleFromView(_ text: String) {
        if !isEditable {
                    setTitlePositionForTextAlignment()
                }
                
                adjustTopTextInset()
                hintLabel.alpha = text.isEmpty ? 1.0 : 0.0
                
                let r = textRect()
                hintLabel.frame = CGRect(x: r.origin.x, y: r.origin.y, width: hintLabel.frame.size.width, height: hintLabel.frame.size.height)
                
                
        //        setTitlePositionForTextAlignment()
                //Jaimesh
                
                //
                let isResp = isFirstResponder
                if isResp && !text.isEmpty {
                    title.textColor = titleActiveTextColour
        //            rightView.isHidden = false
                }
        //        else {
        //            title.textColor = titleActiveTextColour
        //            rightView.isHidden = true
        //        }
                
                // Should we show or hide the title label?
                if text.isEmpty {
                    // Hide
                    hideTitle(isResp)
                    self.tintColor = Colors.lightGray.returnColor() //titleTextColour //Jaimesh
                } else {
                    // Show
                    showTitle(isResp)
                    self.tintColor = Colors.gray.returnColor()//Colors.black.returnColor() //Jaimesh
                }
                self.layoutIfNeeded()
    }
    
    
	fileprivate func setup() {
//		initialTopInset = textContainerInset.top
		textContainer.lineFragmentPadding = 0.0
        titleActiveTextColour = UIColor.gray//tintColor - Jaimesh
        
        self.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        
        self.clipsToBounds = true //Jaimesh
        
		// Placeholder label
		hintLabel.font = titleFont
		hintLabel.text = hint
		hintLabel.numberOfLines = 1
//		hintLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
		hintLabel.backgroundColor = UIColor.clear
		hintLabel.textColor = placeholderTextColor
		insertSubview(hintLabel, at:0)
        
		// Set up title label
		title.alpha = 0.0
		title.font = Fonts.Regular.returnFont(size: 13.0)
		title.textColor = titleTextColour
        title.backgroundColor = .white
		if !hint.isEmpty {
			title.text = hint
			title.sizeToFit()
		}
//        titleView.addSubview(title)
        self.addSubview(title)
		
		// Observers
		if !isIB {
			let nc = NotificationCenter.default
			nc.addObserver(self, selector:#selector(UIView.layoutSubviews), name: UITextView.textDidChangeNotification, object:self)
            nc.addObserver(self, selector:#selector(UIView.layoutSubviews), name: UITextView.textDidBeginEditingNotification, object:self)
			nc.addObserver(self, selector:#selector(UIView.layoutSubviews), name:UITextView.textDidEndEditingNotification, object:self)
		}
	}

	fileprivate func adjustTopTextInset() {
//		var inset = textContainerInset
//		inset.top = initialTopInset + title.font.lineHeight + hintYPadding
//		textContainerInset = inset
	}
	
	fileprivate func textRect()->CGRect {
		var r = bounds.inset(by: contentInset)
		r.origin.x += textContainer.lineFragmentPadding
		r.origin.y += textContainerInset.top
		return r.integral
	}
    
	fileprivate func setTitlePositionForTextAlignment() {
		var titleLabelX = textRect().origin.x
		var placeholderX = titleLabelX
		if textAlignment == NSTextAlignment.center {
			titleLabelX = (frame.size.width - title.frame.size.width) * 0.5
			placeholderX = (frame.size.width - hintLabel.frame.size.width) * 0.5
		} else if textAlignment == NSTextAlignment.right {
			titleLabelX = frame.size.width - title.frame.size.width
			placeholderX = frame.size.width - hintLabel.frame.size.width
		}
		var r = title.frame
		r.origin.x = titleLabelX
//        r.size.width = r.size.width + 4// Jaimesh
//		title.frame = r
        title.sizeToFit()
        title.frame = CGRect(x:r.origin.x, y:title.frame.origin.y, width:title.frame.size.width+4, height:title.frame.size.height)
//        title.textAlignment = .center// Jaimesh
		r = hintLabel.frame
//        r.size.width = r.size.width + 4// Jaimesh
		r.origin.x = placeholderX
//        hintLabel.textAlignment = .center// Jaimesh
		hintLabel.frame = r
	}
	
	fileprivate func showTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseOut], animations:{
                // Animation
                self.title.alpha = 1.0
                var r = self.title.frame
                r.origin.x = 20 //Jaimesh
                r.origin.y = self.titleYPadding + self.contentOffset.y
//                r.size.width = self.frame.size.width //Jaimesh
                self.title.frame = r
			}, completion:nil)
	}
	
	fileprivate func hideTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseIn], animations:{
                // Animation
                self.title.alpha = 0.0
                var r = self.title.frame
                r.origin.x = 0 //Jaimesh
                r.origin.y = self.title.font.lineHeight + self.hintYPadding
                self.title.frame = r
			}, completion:nil)
	}
    
}
