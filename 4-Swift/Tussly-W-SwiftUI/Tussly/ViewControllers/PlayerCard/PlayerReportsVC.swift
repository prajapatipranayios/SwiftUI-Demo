//
//  PlayerReportsVC.swift
//  Tussly
//
//  Created by Auxano on 09/05/24.
//  Copyright © 2024 Auxano. All rights reserved.
//

import UIKit
import WebKit

class PlayerReportsVC: UIViewController {

    // MARK: - Outlet
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBAction func btnBackTap(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        playerTabVC!().selectedIndex = -1
        playerTabVC!().cvPlayerTabs.selectedIndex = -1
        playerTabVC!().cvPlayerTabs.reloadData()
    }
    @IBOutlet weak var lblScreenTitle: UILabel!
    @IBOutlet weak var viewWebView: UIView!
    
    // MARK: - variable
    
    var playerTabVC: (()->PlayerCardTabVC)?
    var strScreenTitle: String = "Player Reports"
    private var stringContent = ""
    var strBaseUrl: String = ""
    var intUserId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblScreenTitle.text = self.strScreenTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.playerTabVC!().selectedIndex == 4 {
            self.playerTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.playerTabVC!().cvPlayerTabs.frame.origin.y),animate: true)
        }
        
        stringContent = "\(strBaseUrl)/mobile-reports/\(self.intUserId)"
        print(stringContent)
        //stringContent = "https://picsum.photos/"
        self.setupWebView(htmlContent: stringContent)
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
        wkwebView.scrollView.alwaysBounceHorizontal = false
        wkwebView.isMultipleTouchEnabled = false
        
        //wkwebView.scrollView.delegate = self
        //wkwebView.navigationDelegate = self
        
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
}

extension PlayerReportsVC : WKNavigationDelegate {
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
