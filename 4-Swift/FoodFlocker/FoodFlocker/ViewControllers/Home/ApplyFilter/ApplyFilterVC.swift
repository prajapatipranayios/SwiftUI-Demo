//
//  ApplyFilterVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 02/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ApplyFilterVC: UIViewController {

    //Outlets
    @IBOutlet weak var bottomViewContainer: NSLayoutConstraint!
    @IBOutlet weak var heightViewDistance: NSLayoutConstraint!
    @IBOutlet weak var bottomViewDistance: NSLayoutConstraint!
    @IBOutlet weak var viewDistance: UIView!

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewTop: UIView!

    @IBOutlet weak var viewFilters: UIView!
    @IBOutlet weak var viewSort: UIView!

    @IBOutlet var btnFilters: [UIButton]!
    @IBOutlet var lblDots: [UILabel]!
    @IBOutlet var btnPostType: [UIButton]!
    @IBOutlet var btnEventType: [UIButton]!
    @IBOutlet var btnApplySort: [UIButton]!

    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var slider: UISlider!

    var selectedSortIndex: Int = -1
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var updateFrame: ((Int, [String: Any])->Void)?
    
    var ontapApply: (([String: Any])->Void)?
    
    var filterData = [String: Any]()
    var tmpFilterData = [String: Any]()
    
    var selectedPost = [Int]()
    var selectedEvent = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.bottomViewContainer.constant = -self.viewContainer.frame.size.height
        self.view.layoutIfNeeded()
        
        tmpFilterData = filterData
        
        DispatchQueue.main.async {
            self.setupUI()
            self.setData()
        }
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        view.bringSubviewToFront(viewContainer)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.openBottomSheet()
//        }
    }
    
    // MARK: - UI Methods
    func setData() {
//        self.dictParams.updateValue(filterData["distance"]!, forKey: "distance")
//        self.dictParams.updateValue(filterData["sortBy"]!, forKey: "sortOption")
//        self.dictParams.updateValue(["post": filterData["postType"], "event": filterData["eventType"]], forKey: "filterOption")
//
        
        slider.value = filterData["distance"] as! Float
        
        selectedPost = filterData["postType"] as! [Int]
        if selectedPost.contains(3) {
            selectedPost.remove(at: selectedPost.firstIndex(of: 3)!)
        }
        
        selectedEvent = filterData["eventType"] as! [Int]
        if selectedEvent.contains(3) {
            selectedEvent.remove(at: selectedEvent.firstIndex(of: 3)!)
        }
        
        setSortValue(value: filterData["sortBy"] as! String)
        
        for btn in btnPostType {
            
            if selectedPost.contains(btn.tag+1) {
                btnPostType[btn.tag].backgroundColor = Colors.themeGreen.returnColor()
                btnPostType[btn.tag].setTitleColor(UIColor.white, for: .normal)
                btnPostType[btn.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor
            }else {
                btnPostType[btn.tag].backgroundColor = UIColor.clear
                btnPostType[btn.tag].setTitleColor(UIColor.black, for: .normal)
                btnPostType[btn.tag].layer.borderColor = Colors.lightGray.returnColor().cgColor
            }
        }
        
        for btn in btnEventType {
            if selectedEvent.contains(btn.tag+1) {
                btnEventType[btn.tag].backgroundColor = Colors.themeGreen.returnColor()
                btnEventType[btn.tag].setTitleColor(UIColor.white, for: .normal)
                btnEventType[btn.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor
            }else {
                btnEventType[btn.tag].backgroundColor = UIColor.clear
                btnEventType[btn.tag].setTitleColor(UIColor.black, for: .normal)
                btnEventType[btn.tag].layer.borderColor = Colors.lightGray.returnColor().cgColor
            }
        }
        
    }
    
    func openBottomSheet() {
//        UIView.animate(withDuration: 0.5, animations: {
            self.bottomViewContainer.constant = 0
            self.view.layoutIfNeeded()
//        })
    }
    
    func closeBottomSheet() {
//        UIView.animate(withDuration: 0.5, animations: {
//            self.bottomViewContainer.constant = -self.viewContainer.frame.size.height
////            if #available(iOS 11.0, *) {
////                self.bottomViewContainer.constant = -self.viewContainer.frame.size.height
////            } else {
////                self.bottomViewContainer.constant = -(self.viewBottomSheet.frame.height + self.view.layoutMargins.bottom + 16.0)
////            }
//            self.view.layoutIfNeeded()
//        }) { (true) in
            self.dismiss(animated: true) {
                
                if self.selectedPost.count > 1 {
                    self.selectedPost.append(3)
                }
                
                if self.selectedEvent.count > 1 {
                    self.selectedEvent.append(3)
                }
                
                self.filterData["postType"] = self.selectedPost
                self.filterData["eventType"] = self.selectedEvent
                
                self.ontapApply!(self.filterData)
            }
//        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewContainer.roundCorners(corners: [.topLeft,.topRight], radius: 30.0)
        for lbl in lblDots {
            lbl.layer.cornerRadius = lbl.frame.size.height / 2
            lbl.clipsToBounds = true
        }
    }

    func setupUI() {
        viewTop.addShadow(offset: CGSize(width: 0, height: 4.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
        
        btnFilters[0].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
        
        viewFilters.isHidden = false
        viewSort.isHidden = true
        
        lblDots[0].isHidden = false
        lblDots[1].isHidden = true

        btnPostType[0].backgroundColor = Colors.themeGreen.returnColor()
        btnPostType[0].setTitleColor(UIColor.white, for: .normal)
        
        btnEventType[0].backgroundColor = Colors.themeGreen.returnColor()
        btnEventType[0].setTitleColor(UIColor.white, for: .normal)

        for btn in btnPostType {
            btn.layer.cornerRadius = btn.frame.size.height / 2
            btn.layer.borderWidth = 1.0
            btn.layer.borderColor = Colors.lightGray.returnColor().cgColor
        }
        
        for btn in btnEventType {
            btn.layer.cornerRadius = btn.frame.size.height / 2
            btn.layer.borderWidth = 1.0
            btn.layer.borderColor = Colors.lightGray.returnColor().cgColor
        }
        
        btnApply.backgroundColor = Colors.orange.returnColor()
        btnApply.layer.cornerRadius = btnApply.frame.size.height / 2
        btnReset.layer.cornerRadius = btnReset.frame.size.height / 2

        setAttributedBtnTitle(btn: btnApplySort[1], length: 6)
        setAttributedBtnTitle(btn: btnApplySort[2], length: 9)

    }
    
    func setAttributedBtnTitle(btn: UIButton, length: Int) {
        let attributedString = NSMutableAttributedString(string: btn.titleLabel!.text!, attributes: [NSAttributedString.Key.font: Fonts.Light.returnFont(size: 18.0)])
        attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 18.0), range: NSRange(location: 0, length: length))

        btn.setAttributedTitle(attributedString, for: .normal)
    }
    
    // MARK: - Button Click Events
    @IBAction func changeSliderKM(_ sender: UISlider) {
        filterData["distance"] = sender.value
    }
    
    
    @IBAction func onTapFilters(_ sender: UIButton) {
        if sender.tag == 0 {
            btnFilters[0].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
            btnFilters[1].setTitleColor(Colors.lightGray.returnColor(), for: .normal)
            viewFilters.isHidden = false
            viewSort.isHidden = true
            lblDots[0].isHidden = false
            lblDots[1].isHidden = true
            
            bottomViewDistance.constant = 24.0
            heightViewDistance.constant = 71.5
            viewDistance.isHidden = false
            
        } else {
            btnFilters[1].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
            btnFilters[0].setTitleColor(Colors.lightGray.returnColor(), for: .normal)
            viewFilters.isHidden = true
            viewSort.isHidden = false
            lblDots[0].isHidden = true
            lblDots[1].isHidden = false
            
            bottomViewDistance.constant = 0
            heightViewDistance.constant = 0
            viewDistance.isHidden = true
        }
        viewContainer.layoutIfNeeded()
        if updateFrame != nil {
            self.dismiss(animated: false) {
                self.updateFrame!(sender.tag, self.filterData)
            }
        }
    }
    
    @IBAction func onTapPostType(_ sender: UIButton) {
        if !selectedPost.contains(sender.tag+1) {
            selectedPost.append(sender.tag+1)
            btnPostType[sender.tag].backgroundColor = Colors.themeGreen.returnColor()
            btnPostType[sender.tag].setTitleColor(UIColor.white, for: .normal)
        }else {
            selectedPost.remove(at: selectedPost.firstIndex(of: sender.tag+1)!)
            btnPostType[sender.tag].backgroundColor = UIColor.clear
            btnPostType[sender.tag].setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    @IBAction func onTapEventType(_ sender: UIButton) {
        if !selectedEvent.contains(sender.tag+1) {
            selectedEvent.append(sender.tag+1)
            btnEventType[sender.tag].backgroundColor = Colors.themeGreen.returnColor()
            btnEventType[sender.tag].setTitleColor(UIColor.white, for: .normal)
        }else {
            selectedEvent.remove(at: selectedEvent.firstIndex(of: sender.tag+1)!)
            btnEventType[sender.tag].backgroundColor = UIColor.clear
            btnEventType[sender.tag].setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    @IBAction func onTapApply(_ sender: UIButton) {
        closeBottomSheet()
//        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapReset(_ sender: UIButton) {
//        filterData = tmpFilterData
        filterData["distance"] = Float(15.0)
        filterData["postType"] = [1,2,3]
        filterData["eventType"] = [1,2,3]
        filterData["sortBy"] = "distance"
        
        setData()
    }
    
    @IBAction func onTapSortOptions(_ sender: UIButton) {
        selectedSortIndex = sender.tag
        for btn in btnApplySort {
            btn.isSelected = sender.tag == btn.tag ? true : false
        }
        
        setSortValue(index: sender.tag)
    }
    
    func setSortValue(index: Int) {
        switch index {
        case 0:
            filterData["sortBy"] = "distance"
        case 1:
            filterData["sortBy"] = "createdAt"
        case 2:
            filterData["sortBy"] = "rating"
        case 3:
            filterData["sortBy"] = "viewCount"
        default:
            break
        }
    }
    
    func setSortValue(value: String) {
        for btn in btnApplySort {
            btn.isSelected = false
        }
        
        switch value {
        case "distance":
            btnApplySort[0].isSelected = true
        case "createdAt":
            btnApplySort[0].isSelected = true
        case "rating":
            btnApplySort[0].isSelected = true
        case "viewCount":
            btnApplySort[0].isSelected = true
        default:
            break
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
