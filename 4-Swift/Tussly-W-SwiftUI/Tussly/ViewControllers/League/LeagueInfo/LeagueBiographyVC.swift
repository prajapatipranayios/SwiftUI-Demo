//
//  LeagueInfoVC.swift
//  Tussly
//
//  Created by Auxano on 27/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import WebKit


class LeagueBiographyVC: UIViewController, UIScrollViewDelegate {

    // MARK: - Variables
    var stringContent = ""
    var isBio = false
    var isCodeOfConduct = false
    var isRules = false
    var leagueInfoVC: (()->LeagueInfoVC)?
    var strTitle = ""
    
    // MARK: - Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var viewWebView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if isBio {
            self.lblTitle.text = strTitle//"Overview"
            self.lblDesc.isHidden = true
            //self.lblDesc.text = APIManager.sharedManager.content?.biography ?? ""
            //self.lblDesc.attributedText = (APIManager.sharedManager.content?.biography ?? "").htmlToAttributedString
            //stringContent = APIManager.sharedManager.content?.biography ?? ""
            //stringContent = APIManager.sharedManager.content?.biographyLink ?? ""
            self.setupWebView(htmlContent: stringContent)
            print(stringContent)
        }
        else if isCodeOfConduct {
            self.lblTitle.text = "Code of Conduct"
            stringContent = APIManager.sharedManager.content?.biography ?? ""
            self.setupWebView(htmlContent: stringContent)
            print(stringContent)
            self.lblDesc.isHidden = true
        }
        else if isRules {
            self.lblDesc.isHidden = true
            self.lblTitle.text = "Rules & Regulations"
            stringContent = APIManager.sharedManager.content?.biography ?? ""
            self.setupWebView(htmlContent: stringContent)
            print(stringContent)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isBio {
            self.leagueInfoVC!().setContentSize()
        }
    }

    // MARK: - UI Methods

    func setupWebView(htmlContent: String) {
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"

        let userScript = WKUserScript(source: jscript, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController

        let wkwebView = WKWebView(frame: viewWebView.frame, configuration: wkWebConfig)
        wkwebView.scrollView.bounces = false
        wkwebView.translatesAutoresizingMaskIntoConstraints = false
        wkwebView.scrollView.delegate = self
        wkwebView.scrollView.alwaysBounceHorizontal = false
        wkwebView.isMultipleTouchEnabled = false
        // By Pranay
        wkwebView.navigationDelegate = self
        // .
        
        //wkwebView.loadHTMLString(htmlContent, baseURL: nil)
        let link = URL(string: htmlContent)!
        let request = URLRequest(url: link)
        wkwebView.load(request)
        
        viewWebView.addSubview(wkwebView)
        wkwebView.topAnchor.constraint(equalTo: viewWebView.topAnchor, constant: 0.0).isActive = true
        wkwebView.bottomAnchor.constraint(equalTo: viewWebView.bottomAnchor, constant: 0.0).isActive = true
        wkwebView.leadingAnchor.constraint(equalTo: viewWebView.leadingAnchor, constant: 0.0).isActive = true
        wkwebView.trailingAnchor.constraint(equalTo: viewWebView.trailingAnchor, constant: 0.0).isActive = true

        viewWebView.layoutIfNeeded()

    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)

    }
}

extension LeagueBiographyVC : WKNavigationDelegate {
    // WKWebViewNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            print("Link activated...")
            guard let url = navigationAction.request.url, let scheme = url.scheme, scheme.contains("http") else {
                decisionHandler(.cancel)
                return
            }
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow) 
        }
    }
}
