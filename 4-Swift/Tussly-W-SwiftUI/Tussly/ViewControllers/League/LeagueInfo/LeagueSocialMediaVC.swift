//
//  LeagueInfoVC.swift
//  Tussly
//

import UIKit

class LeagueSocialMediaVC: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Controls

//    @IBOutlet weak var lblOnlineLan: UILabel!
    @IBOutlet weak var tvSocialMedia : UITableView!

    
    // MARK: - Variables
    var arrSocialMedia = [SocialMedia]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        arrSocialMedia = (APIManager.sharedManager.leagueInfo?.socialMedias)!
        
        tvSocialMedia.register(UINib(nibName: "SocialMediaCell", bundle: nil), forCellReuseIdentifier: "SocialMediaCell")
        tvSocialMedia.rowHeight = UITableView.automaticDimension
        tvSocialMedia.estimatedRowHeight = 100.0
        tvSocialMedia.reloadData()
    }
    
    // MARK: - UI Methods
    
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)

    }
}


// MARK: - UITableViewDelegate

extension LeagueSocialMediaVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSocialMedia.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SocialMediaCell", for: indexPath) as! SocialMediaCell
        
        cell.lblSocialMediaName.text = arrSocialMedia[indexPath.row].value
        cell.ivSocialMedia.setImage(imageUrl: arrSocialMedia[indexPath.row].imageUrl ?? "") 
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
