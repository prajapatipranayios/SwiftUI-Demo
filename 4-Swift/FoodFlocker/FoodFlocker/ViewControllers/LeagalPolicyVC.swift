//
//  LeagalPolicyVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 11/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import WebKit

class LeagalPolicyVC: UIViewController, UIScrollViewDelegate, WKNavigationDelegate {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewTermsContainer: UIView!
    
    @IBOutlet var btnTerms: [UIButton]!
    @IBOutlet var lblDots: [UILabel]!
    
    @IBOutlet weak var viewContainer: UIView!

    var selectedTabIndex = 0
    
    var termsPolicies = [TermsPolicyContent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        getTermsPolicy()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for lbl in lblDots {
            lbl.layer.cornerRadius = lbl.frame.size.height / 2
            lbl.clipsToBounds = true
            lbl.backgroundColor = UIColor.white
        }
    }
    
    func setupUI() {
        viewTopContainer.roundCorners(radius: 20.0, arrCornersiOS11: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], arrCornersBelowiOS11: [.bottomRight , .bottomLeft])
        viewTopContainer.layer.masksToBounds = false
        viewTopContainer.layer.shadowRadius = 3.0
        viewTopContainer.layer.shadowOpacity = 0.3
        viewTopContainer.layer.shadowColor = UIColor.gray.cgColor
        viewTopContainer.layer.shadowOffset = CGSize(width: 0 , height:3)

        viewTermsContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: Colors.themeGreen.returnColor())
    }
    
    func setupWebView(htmlContent: String) {
        if #available(iOS 10, *) {
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let userScript = WKUserScript(source: jscript, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
            let wkUController = WKUserContentController()
            wkUController.addUserScript(userScript)
            let wkWebConfig = WKWebViewConfiguration()
            wkWebConfig.userContentController = wkUController
            
            let wkwebView = WKWebView(frame: viewContainer.frame, configuration: wkWebConfig)
            wkwebView.translatesAutoresizingMaskIntoConstraints = false
            wkwebView.scrollView.delegate = self
            wkwebView.scrollView.alwaysBounceHorizontal = false
            wkwebView.isMultipleTouchEnabled = false
            wkwebView.navigationDelegate = self
            wkwebView.loadHTMLString(htmlContent, baseURL: nil)
            
            viewContainer.addSubview(wkwebView)
            wkwebView.topAnchor.constraint(equalTo: viewContainer.topAnchor, constant: 0.0).isActive = true
            wkwebView.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor, constant: 0.0).isActive = true
            wkwebView.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 0.0).isActive = true
            wkwebView.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: 0.0).isActive = true
        } else {
            
        }
        viewContainer.layoutIfNeeded()
    }
    
    // MARK: - Button Click Events
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapFilters(_ sender: UIButton) {
        selectedTabIndex = sender.tag
        
        if self.termsPolicies.count > 0 {
            showLoading()
            setupWebView(htmlContent: self.termsPolicies[self.selectedTabIndex].content)
        }
        	
        if sender.tag == 0 {
            btnTerms[0].setTitleColor(UIColor.white, for: .normal)
            btnTerms[1].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = false
            lblDots[1].isHidden = true
        } else {
            btnTerms[1].setTitleColor(UIColor.white, for: .normal)
            btnTerms[0].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = true
            lblDots[1].isHidden = false
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
    
    // MARK: - Webservices

    func getTermsPolicy() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTermsPolicy()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TERMS_POLICY, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.termsPolicies = (response?.result?.termAndPolicy)!
                DispatchQueue.main.async {
                    self.onTapFilters(self.btnTerms[self.selectedTabIndex])
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        //Show loader
//        showLoading()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //Hide loader
        hideLoading()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //Hide loader
        hideLoading()
    }
    
}
