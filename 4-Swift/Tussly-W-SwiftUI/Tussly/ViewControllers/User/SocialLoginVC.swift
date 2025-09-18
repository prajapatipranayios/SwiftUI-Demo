//
//  SocialLoginVC.swift
//  Tussly
//
//  Created by Auxano on 23/12/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit
import WebKit

protocol socialURLDelegate {
    func getToken(token: String)
}

class SocialLoginVC: UIViewController , WKUIDelegate, WKNavigationDelegate {
    var webView: WKWebView!
    var isDiscoredLogin = 0
    var delegate : socialURLDelegate?

    //TwichUrl : http://14.99.147.156:9898/tussly_new/app/public/auth/redirect/twitch

    //DiscordUrl : https://discord.com/api/oauth2/authorize?client_id=900747847333470288&redirect_uri=http%3A%2F%2F14.99.147.156%3A9898%2Ftussly_new%2Fapp%2Fpublic%2Fsocial%2Fredirect%2Fdiscord%2F&response_type=code&scope=identify%20guilds

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        var loginTypeurl = ""
        if isDiscoredLogin == 0 {
            loginTypeurl = "https://discord.com/api/oauth2/authorize?client_id=900747847333470288&redirect_uri=http%3A%2F%2F14.99.147.156%3A9898%2Ftussly_new%2Fapp%2Fpublic%2Fsocial%2Fredirect%2Fdiscord%2F&response_type=code&scope=identify%20guilds"
        } else {
            loginTypeurl = "http://14.99.147.156:9898/tussly_new/app/public/auth/redirect/twitch"
        }
        let myURL = URL(string: loginTypeurl)

       let myRequest = URLRequest(url: myURL!)

       webView.load(myRequest)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func loadView() {
       let webConfiguration = WKWebViewConfiguration()
       webView = WKWebView(frame: .zero, configuration: webConfiguration)
       webView.uiDelegate = self
        webView.navigationDelegate = self
       view = webView
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url != nil {
            let newURL = URL(string: "\(String(describing: webView.url))")!
            if newURL.valueOf("token") != "" || newURL.valueOf("token") != nil {
                self.delegate?.getToken(token: "\(newURL.valueOf("token") ?? "")")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Not Found")
            }
            print(newURL.valueOf("token") ?? "")
        }
      }
}

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
