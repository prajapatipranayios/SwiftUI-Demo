//
//  FloatLabelTextView.swift
//  - Custom TextView to make its UI as per the shared design.
//
//  Created by Jaimesh Patel on 28/11/14.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

@IBDesignable class TLTextView: UITextView {
    
	let animationDuration = 0.3
	let placeholderTextColor = Colors.gray.returnColor()
	fileprivate var isIB = false
	fileprivate var title = UILabel()
	fileprivate var hintLabel = UILabel()
    fileprivate var rightView = UIView()
	fileprivate var initialTopInset:CGFloat = 0
	
	// MARK:- Properties
    
    override var tintColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let startingPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let endingPoint = CGPoint(x: (rect.maxX) + 40, y: rect.maxY)
        
        let path = UIBezierPath()
        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        path.lineWidth = 2.0
        
        tintColor.setStroke()
        path.stroke()
    }
    
	override var accessibilityLabel:String? {
		get {
			if text.isEmpty {
				return title.text!
			} else {
				return text
			}
		}
		set {
		}
	}
	
    var titleFont:UIFont = Fonts.Regular.returnFont(size: 12.0) {
		didSet {
			title.font = titleFont
		}
	}
	
	@IBInspectable var hint:String = "" {
		didSet {
			title.text = hint
			title.sizeToFit()
			var r = title.frame
			r.size.width = frame.size.width
			title.frame = r
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
	
	@IBInspectable var titleYPadding:CGFloat = 0.0 {
		didSet {
			var r = title.frame
			r.origin.y = titleYPadding
			title.frame = r
		}
	}
	
	@IBInspectable var titleTextColour:UIColor = UIColor.gray {
		didSet {
			if !isFirstResponder {
				title.textColor = titleTextColour
			}
		}
	}
	
	@IBInspectable var titleActiveTextColour:UIColor = UIColor.cyan {
		didSet {
			if isFirstResponder {
				title.textColor = titleActiveTextColour
			}
		}
	}
    
    var imgViewHeight = 20
    
    @IBInspectable var rightBtnView: UIImage?
            {
            didSet {
                rightView = UIView(frame: CGRect(x: self.frame.size.width - 30, y: 26, width: 20, height: 20))
                self.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 40)
                let btn = UIButton(frame: CGRect(x: 0, y: 0, width: imgViewHeight, height: imgViewHeight))
                btn.clipsToBounds = true

                btn.setImage(rightBtnView, for: .normal)
                btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
                rightView.addSubview(btn)

                self.addSubview(rightView)
            }
        }
        
        @objc func closeTapped() {
            self.text = ""
            rightView.isHidden = true
            self.resignFirstResponder()
            self.becomeFirstResponder()
        }
	
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
		adjustTopTextInset()
		hintLabel.alpha = text.isEmpty ? 1.0 : 0.0
		let r = textRect()
		hintLabel.frame = CGRect(x:r.origin.x, y:r.origin.y, width:hintLabel.frame.size.width, height:hintLabel.frame.size.height)
		setTitlePositionForTextAlignment()
		let isResp = isFirstResponder
		if isResp && !text.isEmpty {
			title.textColor = titleActiveTextColour
            rightView.isHidden = false
		} else {
			title.textColor = titleTextColour
            rightView.isHidden = true
		}
		// Should we show or hide the title label?
		if text.isEmpty {
			// Hide
			hideTitle(isResp)
            self.tintColor = titleTextColour //Jaimesh
		} else {
			// Show
			showTitle(isResp)
            self.tintColor = Colors.black.returnColor() //Jaimesh
		}
        self.layoutIfNeeded()
	}
	
	// MARK:- Private Methods
	fileprivate func setup() {
		initialTopInset = textContainerInset.top
		textContainer.lineFragmentPadding = 0.0
		titleActiveTextColour = tintColor
        
		// Placeholder label
		hintLabel.font = font
		hintLabel.text = hint
		hintLabel.numberOfLines = 0
		hintLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
		hintLabel.backgroundColor = UIColor.clear
		hintLabel.textColor = placeholderTextColor
		insertSubview(hintLabel, at:0)
        
		// Set up title label
		title.alpha = 0.0
		title.font = titleFont
		title.textColor = titleTextColour
		title.backgroundColor = backgroundColor
		if !hint.isEmpty {
			title.text = hint
			title.sizeToFit()
		}
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
		var inset = textContainerInset
		inset.top = initialTopInset + title.font.lineHeight + hintYPadding
		textContainerInset = inset
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
		title.frame = r
		r = hintLabel.frame
		r.origin.x = placeholderX
		hintLabel.frame = r
	}
	
	fileprivate func showTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseOut], animations:{
                // Animation
                self.title.alpha = 1.0
                var r = self.title.frame
                r.origin.y = self.titleYPadding + self.contentOffset.y
                r.size.width = self.frame.size.width //Jaimesh
                self.title.frame = r
			}, completion:nil)
	}
	
	fileprivate func hideTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseIn], animations:{
                // Animation
                self.title.alpha = 0.0
                var r = self.title.frame
                r.origin.y = self.title.font.lineHeight + self.hintYPadding
                self.title.frame = r
			}, completion:nil)
	}
}
