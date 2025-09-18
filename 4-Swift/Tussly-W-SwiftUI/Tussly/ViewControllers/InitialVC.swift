//
//  InitialVC.swift
//  - Initial screen when User is not logged in, this will be first screen visible to User.

//  Tussly
//
//  Created by Jaimesh Patel on 01/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {
    
    // MARK: -Variables
    //var arrTechnology = [[String: String]]()
//    var pageController = TLPageControl()
    // By Pranay
    //var arrTechnology = [Game]()
    // .
    
    // MARK: - Controls
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var imgMyLeagues: UIImageView!
    @IBOutlet weak var viewMyTeams: UIView!
    @IBOutlet weak var viewMyPlayerCard: UIView!
    @IBOutlet weak var imgMyTeams: UIImageView!
    @IBOutlet weak var imgMyPlayerCard: UIImageView!
    //@IBOutlet weak var cvTech: UICollectionView!
    //@IBOutlet weak var btnNext: UIButton!
    //@IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var lblTechnology: UILabel!
    
    @IBOutlet weak var btnSearchTournament: UIButton!
    @IBOutlet weak var btnCreateTournament: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.cvTech.delegate = self
        //self.cvTech.dataSource = self
        DispatchQueue.main.async {
            //self.getGames()
            self.setupUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            if (UserDefaults.standard.value(forKey: UserDefaultType.forBetaPopup) == nil) {
                UserDefaults.standard.set(0, forKey: UserDefaultType.forBetaPopup)
            }
            self.showBetaPopup()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //NotificationCenter.default.removeObserver(self, name: Notification.Name("onTapLogin"), object: nil)
    }
    
    // MARK: - UI Methods
    func setupUI() {
        DispatchQueue.main.async {
//            let layout = UICollectionViewFlowLayout()
//            layout.minimumInteritemSpacing = 0.0
//            layout.minimumLineSpacing = 20.0
//            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            layout.itemSize = CGSize(width: 120, height: self.cvTech.frame.height)
//            layout.scrollDirection = .horizontal
//            self.cvTech?.collectionViewLayout = layout
//            self.cvTech.contentOffset.x = 0
//            self.cvTech.dataSource = self
//            self.cvTech.reloadData()
//            self.cvTech.isPagingEnabled = true
//            self.btnPrev.isHidden = true
//            self.btnNext.isHidden = true
                    
            //pageController.numberOfPages = arrTechnology.count
            //pageController.currentPage = 0
        
            self.imgMyLeagues.layer.cornerRadius = 15.0
            self.imgMyTeams.layer.cornerRadius = 15.0
            self.imgMyPlayerCard.layer.cornerRadius = 15.0
            
            self.btnLogin.layer.cornerRadius = self.btnLogin.frame.size.height/2
            self.btnSignUp.layer.cornerRadius = self.btnSignUp.frame.size.height/2
            
            self.btnSignUp.layer.shadowColor = Colors.black.returnColor().cgColor
            self.btnSignUp.layer.shadowOffset = CGSize(width: 3, height: 3)
            self.btnSignUp.layer.shadowOpacity = 0.1
            self.btnSignUp.layer.shadowRadius = 5.0
            self.lblTechnology.text = "Create a Tournament"
            
            self.btnSearchTournament.layer.cornerRadius = self.btnSearchTournament.frame.size.height/2
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.login), name: Notification.Name("onTapLogin"), object: nil)
        }
    }
    
    @objc func login() {
        self.onTapLogin(UIButton())
    }
    
    func showBetaPopup() {
        if (UserDefaults.standard.value(forKey: UserDefaultType.forBetaPopup)! as! Int) == 0 {
            UserDefaults.standard.set(0, forKey: UserDefaultType.forBetaPopup)
            
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "BetaCustomDialog") as! BetaCustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.mainTitleText = "Welcome to Tussly"
            dialog.titleText = Messages.betaVersionTitle
            dialog.message = Messages.betaVersionMsg
            //dialog.arrHighlightString = ["Players:", "Teams:", "Tournaments:"]
            dialog.tapOK = {
                UserDefaults.standard.set(1, forKey: UserDefaultType.forBetaPopup)
            }
            dialog.btnYesText = Messages.close
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapLogin(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        objVC.initialVC = { return self }
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func onTapSignUp(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func onTapregisterLeague(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.registerForLeague
        dialog.message = Messages.registrationPageYourBrowser
        dialog.btnYesText = Messages.ok
        dialog.btnNoText = Messages.cancel
        dialog.tapOK = {
            if let link = URL(string: APIManager.sharedManager.registerLeagueUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(link)
                } else {
                    UIApplication.shared.openURL(link)
                }
            }
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func didPressNextPrev(_ sender: UIButton) {
//        if sender.tag == 0 {
//            btnNext.isHidden = false
//            btnPrev.isHidden = true
//            self.cvTech.contentOffset = CGPoint(x: 0, y: 0)
//        } else {
//            btnNext.isHidden = true
//            btnPrev.isHidden = false
//            self.cvTech.contentOffset = CGPoint(x: self.cvTech.contentSize.width - self.cvTech.frame.size.width, y: 0)
//        }
//        var contentOffset = CGFloat()
//        let collectionBounds = self.cvTech.bounds
//        if sender.tag == 0 {
//            if self.pageController.currentPage == 1 {
//                btnPrev.isHidden = true
//                if(arrTechnology.count == 1){
//                    btnNext.isHidden = true
//                } else {
//                    btnNext.isHidden = false
//                }
//            } else {
//                btnNext.isHidden = false
//                btnPrev.isHidden = false
//            }
//            contentOffset = CGFloat(floor(self.cvTech.contentOffset.x - collectionBounds.size.width))
//            self.pageController.currentPage -= 1
//        } else {
//            if self.pageController.currentPage == arrTechnology.count - 2 {
//                btnNext.isHidden = true
//                if(arrTechnology.count == 1){
//                    btnPrev.isHidden = true
//                } else {
//                    btnPrev.isHidden = false
//                }
//            }else {
//                btnNext.isHidden = false
//                btnPrev.isHidden = false
//            }
//            contentOffset = CGFloat(floor(self.cvTech.contentOffset.x + collectionBounds.size.width))
//            self.pageController.currentPage += 1
//        }
//        let frame: CGRect = CGRect(x : contentOffset ,y : self.cvTech.contentOffset.y ,width : self.cvTech.frame.width,height : self.cvTech.frame.height)
//        self.cvTech.scrollRectToVisible(frame, animated: true)
//        cvTech.reloadData()
    }
    
    @IBAction func onTapCreatTeam(_ sender: UIButton) {
        if APIManager.sharedManager.user == nil {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.titleText = Messages.createTeam
            dialog.message = Messages.createTeamMsg
            //dialog.lblMessage.textAlignment = .left // By Pranay
            dialog.tapOK = {
                self.onTapLogin(UIButton()) //  By Pranay
            }
            dialog.btnYesText = Messages.login
            dialog.btnNoText = Messages.close
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        } else {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateTeamVC") as! CreateTeamVC
            self.navigationController?.pushViewController(objVC, animated: true)
        }
    }
    
    @IBAction func btnSearchTournamentTap(_ sender: UIButton) {
        if APIManager.sharedManager.user == nil {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.titleText = Messages.search
            dialog.message = Messages.searchMsg
            dialog.arrHighlightString = ["Players:", "Teams:", "Tournaments:"]
            dialog.tapOK = {
                self.onTapLogin(UIButton())
            }
            dialog.btnYesText = Messages.login
            dialog.btnNoText = Messages.close
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
            //self.view!.tusslyTabVC.openSearchView(selectedIndex: 3, fromPlayer: false, fromTournaments: true)
        }
    }
    
    @IBAction func btnPlayerCardTap(_ sender: UIButton) {
        if APIManager.sharedManager.user == nil {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            //dialog.lblMessage.textAlignment = NSTextAlignment.left
            dialog.titleText = Messages.playerCardInitial
            dialog.message = Messages.playerCardInitialMsg
            //dialog.lblMessage.textAlignment = .left // By Pranay
            dialog.tapOK = {
                self.onTapLogin(UIButton())
            }
            dialog.btnYesText = Messages.login
            dialog.btnNoText = Messages.close
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCreateTournamentTap(_ sender: UIButton) {
        if APIManager.sharedManager.user == nil {
//            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
//            dialog.modalPresentationStyle = .overCurrentContext
//            dialog.modalTransitionStyle = .crossDissolve
//            //dialog.lblMessage.textAlignment = NSTextAlignment.left
//            dialog.titleText = "Create Tournament"
//            dialog.message = Messages.playerCardInitialMsg
//            //dialog.lblMessage.textAlignment = .left
//            dialog.tapOK = {
//                self.onTapLogin(UIButton())
//            }
//            dialog.btnYesText = Messages.login
//            dialog.btnNoText = Messages.close
//            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
            
            self.getGames()
            
            /*DispatchQueue.main.async {
                guard let url = URL(string: "\(BASE_HTTP_URL)\("organizer/auth/login")") else {
                    return
                }
                print(url.absoluteString)
                UIApplication.shared.open(url)
            }   //  */
        }
    }
    
    
    // MARK: -API call
    func getGames() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGames()
                }
                return
                     }
           }
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_GAMES, parameters: ["isHomePage": 1]) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.hideLoading()
                if response?.status == 1 {
                    //self.arrTechnology = (response?.result?.games)!
                    //self.setupUI()
                    //guard let url = URL(string: "\(response?.result?.baseUrl ?? "")\("organizer/auth/login")") else {
                    guard let url = URL(string: "\(response?.result?.baseUrl ?? "")\(response?.result?.createTournamentLink ?? "")") else {
                        return
                    }
                    print(url.absoluteString)
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

//extension InitialVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return arrTechnology.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyTechCell", for: indexPath) as! MyTeamCell
//        cell.lblTeamName.text = arrTechnology[indexPath.item].gameFullName ?? ""
//        cell.ivLogo.setImage(imageUrl: arrTechnology[indexPath.item].gameLogo ?? "")
//        
//        if arrTechnology[indexPath.item].status ?? 23 == 23 {
//            cell.lblTeamName.textColor = Colors.border.returnColor()
//            cell.ivLogo.alpha = 0.5
//        } else {
//            cell.lblTeamName.textColor = Colors.black.returnColor()
//            cell.ivLogo.alpha = 1
//        }
//        
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
////        if indexPath.row == arrTechnology.count - 1 {
////            btnNext.isHidden = true
////            btnPrev.isHidden = false
////        } else {
////            btnPrev.isHidden = true
////            btnNext.isHidden = false
////        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView == cvTech {
//            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
//            var isOpenDialog : Bool = true
//            switch arrTechnology[indexPath.item].id ?? 0 {
//            case 11:
//                ///SSBU
//                dialog.currentPage = 0
//                dialog.infoType = 0
//                break
//            case 13:
//                ///SSBM
//                dialog.currentPage = 0
//                dialog.infoType = 3
//                break
//            case 16:
//                ///NASB2
//                dialog.currentPage = 0
//                dialog.infoType = 6
//                break
//            case 14:
//                ///Tekken
//                dialog.currentPage = 0
//                dialog.infoType = 4
//                break
//            case 15:
//                ///VF5
//                dialog.currentPage = 0
//                dialog.infoType = 5
//                break
//            default:
//                isOpenDialog = false
//                break
//            }
//            if isOpenDialog && arrTechnology[indexPath.item].status ?? 23 != 23 {
//                dialog.modalPresentationStyle = .overCurrentContext
//                dialog.modalTransitionStyle = .crossDissolve
//                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
//            }
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 120, height: cvTech.frame.height)
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        //print(scrollView.contentOffset.x)
//        if scrollView.contentOffset.x > 0 {
//            btnNext.isHidden = true
//            btnPrev.isHidden = false
//        } else {
//            btnNext.isHidden = false
//            btnPrev.isHidden = true
//        }
//    }
//    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        
////        pageController.currentPage = Int(scrollView.contentOffset.x) / 140
////        if self.pageController.currentPage == arrTechnology.count - 1 {
////            btnNext.isHidden = true
////            if(arrTechnology.count == 1){
////                btnPrev.isHidden = true
////            } else {
////                btnPrev.isHidden = false
////            }
////        }else if(self.pageController.currentPage == 0){
////            btnNext.isHidden = false
////            btnPrev.isHidden = true
////        } else {
////            btnNext.isHidden = false
////            btnPrev.isHidden = false
////        }
//    }
//}

