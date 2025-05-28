//
//  HistoryVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 27/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatingPanel

class HistoryVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var tvHistory: UITableView!
    @IBOutlet weak var viewEmptyData: UIView!

    var fpc: FloatingPanelController!
    
    var pageNoPosts = 1
    var hasMorePosts = -1

    var postList: [PostEventDetail]?
    var filteredPostList: [PostEventDetail]?
        
    var selectedFilterOption: Int = 0
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var blurView: UIVisualEffectView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        tvHistory.rowHeight = UITableView.automaticDimension
        tvHistory.estimatedRowHeight = 128.0
        
        fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.surfaceView.cornerRadius = 30.0
        fpc.isRemovalInteractionEnabled = true
        
        blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(blurView)
        blurView.isHidden = true
        
        tvHistory.isHidden = true
        viewEmptyData.isHidden = true

        getPostHistory()
    }
    
    func setupUI() {
        self.viewTop.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onTapFilter(_ sender: UIButton) {
        
        let filterDialog = self.storyboard?.instantiateViewController(withIdentifier: "FilterHistoryVC") as? FilterHistoryVC
        filterDialog?.selectedIndex = selectedFilterOption
        filterDialog?.filterHistory = { selectedIndex in
            self.fpc.removePanelFromParent(animated: false, completion: {
                self.selectedFilterOption = selectedIndex
                if selectedIndex != 0 {
                    self.filteredPostList = self.postList?.filter{
                        var status: Bool!
                        if selectedIndex == 1 { //Paid
                            status = (APIManager.sharedManager.user?.id == $0.createdBy && $0.type == "Buy") || (APIManager.sharedManager.user?.id != $0.createdBy && $0.type == "Sell")
                        } else if selectedIndex == 2 { //Received
                            status = (APIManager.sharedManager.user?.id == $0.createdBy && $0.type == "Sell") || (APIManager.sharedManager.user?.id != $0.createdBy && $0.type == "Buy")
                        } else if selectedIndex == 3 { //FREE
                            status = $0.status == "Donate"
                        }
                        return status
                    }
                    
                    if self.filteredPostList!.count > 0 {
                        self.tvHistory.isHidden = false
                        self.viewEmptyData.isHidden = true
                    }else {
                        self.tvHistory.isHidden = true
                        self.viewEmptyData.isHidden = false
                    }
                    
                }else {
                    if self.postList!.count > 0 {
                        self.tvHistory.isHidden = false
                        self.viewEmptyData.isHidden = true
                    }else {
                        self.tvHistory.isHidden = true
                        self.viewEmptyData.isHidden = false
                    }
                }
                self.tvHistory.reloadData()
                self.blurView.isHidden = true
            })
        }
        
        fpc.set(contentViewController: filterDialog)
        fpc.addPanel(toParent: self, animated: true)
        blurView.isHidden = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Webservices
    
    func getPostHistory() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getPostHistory()
                }
            }
            return
        }
        
        let params = ["page": pageNoPosts]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_POST_HISTORY, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            DispatchQueue.main.async {
                if response?.status == 1 {
                    
                    print((response?.result?.postList)!)
                    
                    if self.postList != nil {
                        self.postList?.append(contentsOf: (response?.result?.postList)!)
                    } else {
                        self.postList = (response?.result?.postList)!
                    }
                    
                    if self.postList!.count > 0 {
                        self.tvHistory.isHidden = false
                        self.viewEmptyData.isHidden = true

                        self.pageNoPosts += 1
                        self.hasMorePosts = (response?.result?.hasMore)!
                        
                        self.tvHistory.dataSource = self
                        self.tvHistory.delegate = self
                        self.tvHistory.reloadData()
                    
                    }else {
                        self.tvHistory.isHidden = true
                        self.viewEmptyData.isHidden = false
                    }
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
}

extension HistoryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedFilterOption == 0 {
            return postList!.count
        } else {
            return filteredPostList!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTVCell", for: indexPath) as! HistoryTVCell
        
        let post = selectedFilterOption == 0 ? postList![indexPath.row] : filteredPostList![indexPath.row]
        
        cell.ivHistory.setImage(imageUrl: post.mediaImage!)
        cell.lblDuration.text = post.requestTime
        
        if post.status == "Donate" { //FREE
            cell.lblPrice.textColor = Colors.themeGreen.returnColor()
            cell.lblPrice.text = "FREE"
            if APIManager.sharedManager.user?.id == post.createdBy {
                
                //new cell - You give donation of "post title" to "username"
                let attributedString = NSMutableAttributedString(string: "You gave donation for \(post.title) to \(post.name)", attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0)])
                
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.gray.returnColor(), range: NSRange(location: 0, length: "You gave donation for \(post.title) to \(post.name)".trimmedString.count))
                
                attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 16.0), range: NSRange(location: "You gave donation for ".count, length: post.title.count))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: "You gave donation for ".count, length: post.title.count))
                
                
                attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 16.0), range: NSRange(location: "You gave donation for \(post.title) to ".count, length: post.name.count))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: "You gave donation for \(post.title) to ".count, length: post.name.count))

                cell.lblHistory.attributedText = attributedString
            } else {
                
                //cell 2
                let attributedString = NSMutableAttributedString(string: "You received donation for \(post.title) from \(post.name)", attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0)])
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.gray.returnColor(), range: NSRange(location: 0, length: "You received donation for \(post.title) from \(post.name)".trimmedString.count))
                
                attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 16.0), range: NSRange(location: "You received donation for ".count, length: post.title.count))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: "You received donation for ".count, length: post.title.count))
                
                attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 16.0), range: NSRange(location: "You received donation for \(post.title) from ".count, length: post.name.count))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: "You received donation for \(post.title) from ".count, length: post.name.count))

                cell.lblHistory.attributedText = attributedString
            }
        } else {
            if (APIManager.sharedManager.user?.id == post.createdBy && post.type == "Sell") || (APIManager.sharedManager.user?.id != post.createdBy && post.type == "Buy") { //Received
                
                //cell 3
                let attributedString = NSMutableAttributedString(string: "You received payment for \(post.title) from \(post.name)", attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0)])
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.gray.returnColor(), range: NSRange(location: 0, length: "You received payment for \(post.title) from \(post.name)".trimmedString.count))
                
                attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 16.0), range: NSRange(location: "You received payment for ".count, length: post.title.count))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: "You received payment for ".count, length: post.title.count))
                
                attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 16.0), range: NSRange(location: "You received payment for \(post.title) from ".count, length: post.name.count))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: "You received payment for \(post.title) from ".count, length: post.name.count))

                cell.lblHistory.attributedText = attributedString
                
                cell.lblPrice.textColor = Colors.themeGreen.returnColor()
                cell.lblPrice.text = "+ \(post.amount!)"
            } else if (APIManager.sharedManager.user?.id == post.createdBy && post.type == "Buy") || (APIManager.sharedManager.user?.id != post.createdBy && post.type == "Sell") { //Paid
                
                //cell 1
                let attributedString = NSMutableAttributedString(string: "You purchased \(post.title) from \(post.name)", attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0)])
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.gray.returnColor(), range: NSRange(location: 0, length: "You purchased \(post.title) from \(post.name)".trimmedString.count))
                attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 16.0), range: NSRange(location: "You purchased ".count, length: post.title.count))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: "You purchased ".count, length: post.title.count))
                
                attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 16.0), range: NSRange(location: "You purchased \(post.title) from ".count, length: post.name.count))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: "You purchased \(post.title) from ".count, length: post.name.count))
                
                cell.lblHistory.attributedText = attributedString
                
                cell.lblPrice.textColor = Colors.red.returnColor()
                cell.lblPrice.text = "- \(post.amount!)"
            }
        }
        
//        cell.lblHistory.sizeToFit()
//        cell.lblHistory.layoutIfNeeded()

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == postList!.count - 1 {
            if hasMorePosts == 1 {
                getPostHistory()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
        
        if selectedFilterOption == 0 {
            vc.postId = postList![indexPath.row].postId!
        } else {
            vc.postId = filteredPostList![indexPath.row].postId!
        }
        self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension HistoryVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpc.surfaceView.borderWidth = 0.0
        fpc.surfaceView.borderColor = nil
        return FilterHistoryLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}

public class FilterHistoryLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.half]
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .half: return 300.0
            default: return nil
        }
    }
}
