//
//  CharacterDialog.swift
//  Tussly
//
//  Created by Auxano on 01/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class CharacterSelectionPopupVC: UIViewController, updateCharacterNoDelegate
{
    // MARK: - Variables
    var arrChar = ["A-F","G-K","L-P","Q-U","V-Z"]
    var arrChars = [Characters]()
    var arrNames = [[Characters]]()
    var arrTitle = [String]()
    var isComeFinishRound = true
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var selectedSection = ""
    var sectionIndex = 0
    var rowIndex = -1
    var teamId = 0
    var tapOk: (([Any])->Void)?
    var tapClose: (()->Void)?
    var isFromPlayercard = false
    var isFromNextRound = false
    
    var isUpdateFireStore: Int = 0
    var strCharName: String = ""
    
    
    // MARK: - Controls
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var cvCharName: UICollectionView!
    @IBOutlet weak var tvCharacter: UITableView!
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var viewGameBar: UIView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 15.0
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        btnApply.layer.cornerRadius = 15
        
        if isFromPlayercard == false
        {
            arrChars = APIManager.sharedManager.content?.characters ?? []
        }
        
        selectedSection = arrChar[0]
        arrTitle = ["A-F", "G-K", "L-P", "Q-U", "V-Z"]
        
        cvCharName.register(UINib(nibName: "CharNameCVCell", bundle: nil), forCellWithReuseIdentifier: "CharNameCVCell")
        
        let headerNib = UINib.init(nibName: "CustomCharHeader", bundle: Bundle.main)
        tvCharacter.register(headerNib, forHeaderFooterViewReuseIdentifier: "CustomCharHeader")
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
    }
    
    //MARK: - UI Methods
    func setupUI()
    {
        //Sort characters alphabatically
        let sortedUsers = arrChars.sorted {
            $0.name! < $1.name!
        }
        let arrNew = sortedUsers.map{Array(arrayLiteral: $0.name)[0]}
        
        let arrAF = ["a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F"]
        var cr = [Characters]()
        for i in 0 ..< arrNew.count
        {
            let chr = arrNew[i]?.prefix(1)
            for j in 0 ..< arrAF.count
            {
                if(arrAF[j] == chr!)
                {
                    cr.append(sortedUsers[i])
                }
            }
        }
        arrNames.append(cr)
        
        let arrGK = ["g", "G", "h", "H", "i", "I", "j", "J", "k", "K"]
        var cr1 = [Characters]()
        for i in 0 ..< arrNew.count
        {
            let chr = arrNew[i]?.prefix(1)
            for j in 0 ..< arrGK.count
            {
                if(arrGK[j] == chr!)
                {
                    cr1.append(sortedUsers[i])
                }
            }
        }
        arrNames.append(cr1)
        
        let arrLP = ["l", "L", "m", "M", "n", "N", "o", "O", "p", "P"]
        var cr2 = [Characters]()
        for i in 0 ..< arrNew.count
        {
            let chr = arrNew[i]?.prefix(1)
            for j in 0 ..< arrLP.count
            {
                if(arrLP[j] == chr!)
                {
                    cr2.append(sortedUsers[i])
                }
            }
        }
        arrNames.append(cr2)
        
        let arrQU = ["q", "Q", "r", "R", "s", "S", "t", "T", "u", "U"]
        var cr3 = [Characters]()
        for i in 0 ..< arrNew.count
        {
            let chr = arrNew[i]?.prefix(1)
            for j in 0 ..< arrQU.count
            {
                if(arrQU[j] == chr!)
                {
                    cr3.append(sortedUsers[i])
                }
            }
        }
        arrNames.append(cr3)
        
        let arrVZ = ["v", "V", "w", "W", "x", "X", "y", "Y", "z", "Z"]
        var cr4 = [Characters]()
        for i in 0 ..< arrNew.count
        {
            let chr = arrNew[i]?.prefix(1)
            for j in 0 ..< arrVZ.count
            {
                if(arrVZ[j] == chr!)
                {
                    cr4.append(sortedUsers[i])
                }
            }
        }
        arrNames.append(cr4)
        
        self.view.layoutIfNeeded()
        DispatchQueue.main.async {
            self.cvCharName.reloadData()
            self.tvCharacter.dataSource = self
            self.tvCharacter.delegate = self
            self.tvCharacter.reloadData()
        }
    }
    
    func updateUI(item: [Int], section: Int)
    {
            self.rowIndex = item.first ?? 0
            self.tvCharacter.reloadData()
    }
    
    // MARK: - Button Click Events
    @IBAction func applyTapped(_ sender: UIButton)
    {
        if isFromPlayercard
        {
            if (rowIndex != -1)
            {
                self.dismiss(animated: true, completion: {
                    if self.tapOk != nil
                    {
                        self.tapOk!([self.arrNames, self.sectionIndex, self.rowIndex])
                    }
                })
            }
            else
            {
                self.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            if (rowIndex != -1)
            {
                if rowIndex <= (self.arrNames[self.sectionIndex].count - 1)
                {
                    ///if select same char then not call api and close dialog.
                    if strCharName != (self.arrNames[self.sectionIndex][rowIndex].name ?? "")
                    {
                        setCharacter()
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: {
                                if self.tapOk != nil
                                {
                                    self.tapOk!([self.arrNames, self.sectionIndex, self.rowIndex])
                                }
                            })
                        }
                    }
                }
                else
                {
                    if self.isFromNextRound
                    {
                        self.dismiss(animated: true, completion: {
                            if self.tapClose != nil
                            {
                                self.tapClose!()
                            }
                        })
                    }
                    else
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            else
            {
                if self.isFromNextRound
                {
                    self.dismiss(animated: true, completion: {
                        if self.tapClose != nil
                        {
                            self.tapClose!()
                        }
                    })
                }
                else
                {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: Webservices
    func setCharacter()
    {
        if !Network.reachability.isReachable
        {
            self.isRetryInternet { (isretry) in
                if isretry!
                {
                    self.setCharacter()
                }
            }
            return
        }
        
        showLoading()
        
        var param = [String: Any]()
        param = [
            "leagueId": APIManager.sharedManager.match?.leagueId ?? 0,
            "matchId": APIManager.sharedManager.match?.matchId ?? 0,
            "teamId": self.teamId,
            "defaultCharacterId": self.arrNames[self.sectionIndex][self.rowIndex].id ?? 0,
            "isUpdateFireStore": isUpdateFireStore
        ]
        
        //APIManager.sharedManager.postData(url: APIManager.sharedManager.SET_DEFAULT_CHARACTER, parameters: ["leagueId" : APIManager.sharedManager.match?.leagueId ?? 0, "matchId": APIManager.sharedManager.match?.matchId ?? 0, "teamId":self.teamId, "defaultCharacterId": self.arrNames[self.sectionIndex][self.rowIndex].id ?? 0]) { (response: ApiResponse?, error) in
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SET_DEFAULT_CHARACTER, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1
            {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        if self.tapOk != nil
                        {
                            self.tapOk!([self.arrNames, self.sectionIndex, self.rowIndex])
                        }
                    })
                }
            }
            else
            {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                    if self.isFromNextRound
                    {
                        self.dismiss(animated: true, completion: {
                            if self.tapClose != nil
                            {
                                self.tapClose!()
                            }
                        })
                    }
                    else
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}

//MARK:- UICollectionViewDelegate

extension CharacterSelectionPopupVC : UICollectionViewDelegate,UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrChar.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharNameCVCell", for: indexPath) as! CharNameCVCell
        cell.lblTitle.text = arrChar[indexPath.row]
        
//        if arrNames[indexPath.row].count == 0
//        {
//            cell.lblTitle.textColor = Colors.disable.returnColor()
//        }
//        else
//        {
//            cell.lblTitle.textColor = .black
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectedSection = arrChar[indexPath.row]
        sectionIndex = indexPath.row
        tvCharacter.reloadData()
        
//        if arrNames[sectionIndex].count != 0
//        {
//            tvCharacter.reloadData()
//        }
    }
}

extension CharacterSelectionPopupVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomCharHeader") as! CustomCharHeader
        headerView.customLabel.text = selectedSection
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharNameTVCell", for: indexPath) as! CharNameTVCell
        cell.selectionStyle = .none
        cell.arrName = arrNames[sectionIndex]
        cell.currentSection = sectionIndex
        cell.delegate = self
        cell.cvProfile.reloadData()
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let count = arrNames[sectionIndex].count % 2
        let height = count == 0 ? 0 : 1
        return CGFloat((((arrNames[sectionIndex].count / 2) + height) * 38))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 35
    }
}



