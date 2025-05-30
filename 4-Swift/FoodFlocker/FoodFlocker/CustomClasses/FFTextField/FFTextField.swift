//
//  FFTextField.swift
//  FFTextField
//
//  Created by Fahim Farook on 28/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.


import UIKit

@IBDesignable class FFTextField: UITextField {
	let animationDuration = 0.3
	var title = UILabel()
    
    var leftVw = UIView() //Jaimesh
    var leftImgVw = UIImageView() //Jaimesh
    var inactiveImg: UIImage? //Jaimesh
    var isEditingg: Bool = false //Jaimesh
    var isHideBottomLine = false //Milan
    
	// MARK:- Properties
    
    override var tintColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let startingPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let endingPoint = CGPoint(x: rect.maxX, y: rect.maxY)
        
        let path = UIBezierPath()
        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        path.lineWidth = 0.0
        
        tintColor.setStroke()
        path.stroke()
    }
    
	override var accessibilityLabel:String? {
		get {
			if let txt = text , txt.isEmpty {
				return title.text
			} else {
				return text
			}
		}
		set {
			self.accessibilityLabel = newValue
		}
	}
	
	override var placeholder:String? {
		didSet {
			title.text = placeholder
			title.sizeToFit()
		}
	}
	
	override var attributedPlaceholder:NSAttributedString? {
		didSet {
            title.attributedText = attributedPlaceholder
            title.font.withSize(13.0)
//			title.text = attributedPlaceholder?.string
			title.sizeToFit()
		}
	}
	
    var titleFont:UIFont = Fonts.Regular.returnFont(size: 13.0) { //UIFont.systemFont(ofSize: 12.0)
		didSet {
			title.font = titleFont
			title.sizeToFit()
		}
	}
	
	@IBInspectable var hintYPadding:CGFloat = 0.0

    @IBInspectable var titleYPadding:CGFloat = -8.0 {
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
	
	@IBInspectable var titleActiveTextColour:UIColor! {
		didSet {
			if isFirstResponder {
				title.textColor = titleActiveTextColour
			}
		}
	}
    
    let imgViewHeight = 20
    
    @IBInspectable var leftImgView: UIImage? {
        didSet {
            
            inactiveImg = leftImgView
            
            let mainView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.height / 2 + 4, height: self.frame.size.height))
            
            
            leftVw = UIView(frame: CGRect(x: 0, y: (Int(mainView.frame.size.height) - imgViewHeight) / 2, width: imgViewHeight, height: imgViewHeight))
            leftVw.clipsToBounds = true
            mainView.addSubview(leftVw)
            
            leftImgVw = UIImageView(image: leftImgView)
            leftImgVw.contentMode = .scaleAspectFit
            leftImgVw.frame = CGRect(x: 0, y: 0, width: imgViewHeight, height: imgViewHeight)
            leftVw.addSubview(leftImgVw)
            
            self.leftViewMode = .always
            self.leftView = mainView

        }
    }
    
    @IBInspectable var activeLeftImg: UIImage? //Jaimesh
    
    @IBInspectable var rightBtnView: UIImage?
        {
        didSet {
            let mainView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.height / 2 + 4 + 16, height: self.frame.size.height))

            let btn = UIButton(frame: CGRect(x: 0, y: (Int(mainView.frame.size.height) - imgViewHeight) / 2, width: imgViewHeight, height: imgViewHeight))
            btn.clipsToBounds = true

            btn.setImage(rightBtnView, for: .normal)
            btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
            mainView.addSubview(btn)

//            let imageView = UIImageView(image: leftImgView)
//            imageView.contentMode = .scaleAspectFit
//            imageView.frame = CGRect(x: 0, y: 0, width: imgViewHeight, height: imgViewHeight)
//            view.addSubview(imageView)

            self.rightViewMode = .whileEditing
            self.rightView = mainView
        }
    }
    
    @objc func closeTapped() {
        self.text = ""
//        self.endEditing(true)
    }
		
	// MARK:- Init
	required init?(coder aDecoder:NSCoder) {
		super.init(coder:aDecoder)
		setup()
	}
	
	override init(frame:CGRect) {
		super.init(frame:frame)
		setup()
	}
	
	// MARK:- Overrides
	override func layoutSubviews() {
		super.layoutSubviews()
        if !isEditing {
            setTitlePositionForTextAlignment()
        }
		
		let isResp = isFirstResponder
		if let txt = text , !txt.isEmpty && isResp {
			//title.textColor = titleActiveTextColour
            //title.textColor = UIColor.gray
            self.rightView?.isHidden = false
		} else {
			//title.textColor = titleTextColour
            //title.textColor = UIColor.gray
            if self.text!.isEmpty {
                self.rightView?.isHidden = true
            }else {
                self.rightView?.isHidden = false
            }
            
		}
        
		// Should we show or hide the title label?
		if let txt = text , txt.isEmpty {
			// Hide
			hideTitle(isResp)
            if isHideBottomLine {
                self.tintColor = UIColor.gray
            } else {
                //self.tintColor = titleTextColour //Jaimesh
                self.tintColor = UIColor.gray
            }
		} else {
			// Show
			showTitle(isResp)
            if isHideBottomLine {
                self.tintColor = UIColor.clear
            } else {
                self.tintColor = UIColor.gray //Jaimesh
            }
		}
	}
	
//	override func textRect(forBounds bounds:CGRect) -> CGRect {
//		var r = super.textRect(forBounds: bounds)
//		if let txt = text , !txt.isEmpty {
//			var top = ceil(title.font.lineHeight + hintYPadding)
//			top = min(top, maxTopInset())
//            r = r.inset(by: UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
//		}
//		return r.integral
//	}
//
//	override func editingRect(forBounds bounds:CGRect) -> CGRect {
//		var r = super.editingRect(forBounds: bounds)
//		if let txt = text , !txt.isEmpty {
//			var top = ceil(title.font.lineHeight + hintYPadding)
//			top = min(top, maxTopInset())
//            r = r.inset(by: UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
//		}
//		return r.integral
//	}
	
	override func clearButtonRect(forBounds bounds:CGRect) -> CGRect {
		var r = super.clearButtonRect(forBounds: bounds)
		if let txt = text , !txt.isEmpty {
			var top = ceil(title.font.lineHeight + hintYPadding)
			top = min(top, maxTopInset())
			r = CGRect(x:r.origin.x, y:r.origin.y + (top * 0.5), width:r.size.width, height:r.size.height)
		}
		return r.integral
	}
	
	// MARK:- Public Methods
    
    func setAttributedPlaceholder(_ color: UIColor) {
        if self.placeholder != nil {
            let attributedString = NSMutableAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0)])
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: self.placeholder!.trimmedString.count))
            
            if self.placeholder!.trimmedString.last == "*" {
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red.returnColor(), range: NSRange(location: self.placeholder!.trimmedString.count - 1, length: 1))
            }

            self.attributedPlaceholder = attributedString
            setAttributedTitle(color)
        }
    }

	func setAttributedTitle(_ color: UIColor) {
        if self.placeholder != nil {
            let attributedString = NSMutableAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 13.0)])
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: self.placeholder!.trimmedString.count))
            
            if self.placeholder!.trimmedString.last == "*" {
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red.returnColor(), range: NSRange(location: self.placeholder!.trimmedString.count - 1, length: 1))
            }

            self.title.attributedText = attributedString
        }
    }
    
	// MARK:- Private Methods
	fileprivate func setup() {
        borderStyle = UITextField.BorderStyle.none
		titleActiveTextColour = tintColor
		// Set up title label
		title.alpha = 0.0
		title.font = titleFont
		title.textColor = titleTextColour
		if let str = placeholder , !str.isEmpty {
            self.attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSAttributedString.Key.foregroundColor : Colors.lightGray.returnColor()])
			title.text = str
			title.sizeToFit()
		}
        
		self.addSubview(title)
	}

	fileprivate func maxTopInset()->CGFloat {
		if let fnt = font {
			return max(0, floor(bounds.size.height - fnt.lineHeight - 4.0))
		}
		return 0
	}
	
	fileprivate func setTitlePositionForTextAlignment() {
		let r = textRect(forBounds: bounds)
        var x = isEditingg ? 0 : r.origin.x//r.origin.x - Jaimesh
		if textAlignment == NSTextAlignment.center {
			x = r.origin.x + (r.size.width * 0.5) - title.frame.size.width
		} else if textAlignment == NSTextAlignment.right {
			x = r.origin.x + r.size.width - title.frame.size.width
		}
        
        title.backgroundColor = .white
        
        /* Jaimesh*/
//        title.text = placeholder
//        title.attributedText = attributedPlaceholder

        title.sizeToFit()
		title.frame = CGRect(x:x, y:title.frame.origin.y, width:title.frame.size.width+4, height:title.frame.size.height)
        title.textAlignment = .center
        //Jaimesh
        leftVw.center.y = r.midY
        
        //Set Right Close Button - Jaimesh
//        if rightBtnView != nil {
//            let mainView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.height / 2 + 4 + 16, height: self.frame.size.height))
//
//            let btn = UIButton(frame: CGRect(x: 0, y: (Int(mainView.frame.size.height) - imgViewHeight) / 2, width: imgViewHeight, height: imgViewHeight))
//            btn.clipsToBounds = true
//
//            btn.backgroundColor = UIColor.red
//            btn.setImage(rightBtnView!, for: .normal)
//
//            mainView.addSubview(btn)
//
//            self.rightViewMode = .whileEditing
//            self.rightView = mainView
//        }
        //
	}
	
	fileprivate func showTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseOut], animations:{
				
                // Animation
				self.title.alpha = 1.0
				var r = self.title.frame
                r.origin.x = 20  //Jaimesh
                self.isEditingg = true //Jaimesh
				r.origin.y = self.titleYPadding
                
				self.title.frame = r
                self.leftImgVw.image = self.activeLeftImg //Jaimesh
			}, completion:nil)
	}
	
	fileprivate func hideTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseIn], animations:{
			// Animation
			self.title.alpha = 0.0
			var r = self.title.frame
            r.origin.x = 0
			r.origin.y = self.title.font.lineHeight + self.hintYPadding
			self.title.frame = r
            self.leftImgVw.image = self.inactiveImg //Jaimesh
			}, completion:nil)
	}
}
