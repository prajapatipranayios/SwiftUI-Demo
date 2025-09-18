//
//  LeagueInfoVC.swift
//  Tussly
//

import UIKit

class SocialMediaPopupVC: UIViewController {
    
    // MARK: - Controls
    @IBOutlet weak var tvSocialMedia : UITableView!
    @IBOutlet weak var viewPopup : UIView!
    
    // MARK: - Variables
    var arrSocialMedia = [SocialMedia]()
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewPopup)
        
        viewPopup.layer.cornerRadius = 15
        arrSocialMedia = (APIManager.sharedManager.content?.socialMedias)!  //  By Pranay
        
        tvSocialMedia.register(UINib(nibName: "SocialMediaCell", bundle: nil), forCellReuseIdentifier: "SocialMediaCell")
        tvSocialMedia.rowHeight = UITableView.automaticDimension
        tvSocialMedia.estimatedRowHeight = 100.0
        tvSocialMedia.reloadData()
    }
    
    // MARK: - UI Methods
    
    // MARK: - Button Click Events
    
    @IBAction func onTapClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension SocialMediaPopupVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSocialMedia.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SocialMediaCell", for: indexPath) as! SocialMediaCell
        
        cell.lblSocialMediaName.text = arrSocialMedia[indexPath.row].value
        cell.ivSocialMedia.setImage(imageUrl: arrSocialMedia[indexPath.row].imageUrl ?? "")
        cell.onTapSocialMedia = { index in
            if self.arrSocialMedia[indexPath.row].type == "WhatsApp" {
                //phone number with country code
               let url = "https://api.whatsapp.com/send?phone=(\(self.arrSocialMedia[indexPath.row].value ?? "")"
                    if let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
                        if let whatsappURL = URL(string: urlString) {
                            if UIApplication.shared.canOpenURL(whatsappURL){
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(whatsappURL)
                                }
                            }
                            else {
                                print("Install Whatsapp")
                            }
                        }
                    }
            } else {
                guard let url = URL(string: self.arrSocialMedia[indexPath.row].value ?? "") else {
                  return //be safe
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
