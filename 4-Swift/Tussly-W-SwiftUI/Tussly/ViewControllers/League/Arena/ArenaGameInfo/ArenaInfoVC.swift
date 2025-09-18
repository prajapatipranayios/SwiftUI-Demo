//
//  ArenaInfoVC.swift
//  Tussly
//
//  Created by Auxano on 18/10/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class ArenaInfoVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    var arrTitle = ["Overview",
                    "Lobby",
                    "BattleArena ID Exchange",
                    "Character Selection",
                    "Rock Paper Scissors",
                    "Stage Pick Ban",
                    "Score Reporting",
                    "Dispute System",
                    "Chat"
    ]
    
    var arrDisputeScore = ["Step 1", 
                           "Step 2",
                           "Step 3",
                           "Step 4",
                           "Step 5",
                           "Step 6 (if necessary)"
    ]
    
    var arrDisputePhoto = ["Step 1", 
                           "Step 2",
                           "Step 3",
                           "Step 4",
                           "Step 5",
                           "Step 6",
                           "Step 7",
                           "Step 8 (if necessary)"
    ]
    
    var currentPage = 0
    var infoType = 0 /*[
                      0 : "arena info",
                      1 : "dispute with photo", 
                      2 : "dispute score only",
                      3 : "arena info SSBM",
                      4 : "arena info Tekken",
                      5 : "arena info VF5",
                      6 : "arena info NASB2"
                      ]*/
    
    // MARK: - Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblStepNo: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewDispute: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var cvInfo: UICollectionView!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewBG)
        
        btnClose.layer.cornerRadius = 15
        viewBG.layer.cornerRadius = 15
        //pageControl.numberOfPages = infoType == 0 ? arrTitle.count : infoType == 1 ? 8 : 6
        pageControl.numberOfPages = (infoType == 0 ? arrTitle.count : (infoType == 1 ? 8 : (infoType == 3 ? arrTitle.count : (infoType == 4 ? arrTitle.count : (infoType == 5 ? arrTitle.count : (infoType == 6 ? arrTitle.count : 6))))))
        pageControl.currentPage = currentPage
        
        lblHeader.text = "Arena Information"
        viewDispute.isHidden = true
        headerHeight.constant = 45
        
        if infoType == 0
        {   }
        else if infoType == 3
        {   /// SSBM
            arrTitle[2] = "Connect Code Exchange"
        }
        else if infoType == 4
        {   /// Tekken
            arrTitle[2] = "Player ID Exchange"
        }
        else if infoType == 5
        {   /// VF5
            arrTitle[2] = "Room ID Exchange"
        }
        else if infoType == 6
        {   /// NASB2
            arrTitle[2] = "Lobby Password Exchange"
        }
        else
        {
            viewDispute.isHidden = false
            headerHeight.constant = 65
            lblHeader.text = "Dispute System"
            lblType.text = infoType == 1 ? "Photo Evidence" : "Score Only"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        setTitle()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.layoutCells()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
        
    @objc func willResignActive()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UI Methods
    
    func layoutCells()
    {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: cvInfo.frame.width, height: cvInfo.frame.height)
        layout.scrollDirection = .horizontal
        self.cvInfo.setCollectionViewLayout(layout, animated: true)
        let index = IndexPath(item: currentPage, section: 0)
        cvInfo.scrollToItem(at: index, at: .top, animated: false)
    }
    
    func setTitle()
    {
        if infoType == 0
        {
            lblTitle.text = arrTitle[currentPage]
        }
        else if (infoType == 3) || (infoType == 4) || (infoType == 5) || (infoType == 6)
        {
            lblTitle.text = arrTitle[currentPage]
        }
        else
        {
            lblStepNo.text = infoType == 1 ? arrDisputePhoto[currentPage] : arrDisputeScore[currentPage]
        }
    }
    
    // MARK: - Button Click Events
    @IBAction func closeTapped(_ sender: UIButton)
    {
        NotificationCenter.default.post(name: Notification.Name("DismissInfo"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

extension ArenaInfoVC: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        //return infoType == 0 ? arrTitle.count : infoType == 1 ? 8 : 6
        return (infoType == 0 ? arrTitle.count : (infoType == 1 ? 8 : (infoType == 3 ? arrTitle.count : (infoType == 4 ? arrTitle.count : (infoType == 5 ? arrTitle.count : (infoType == 6 ? arrTitle.count : 6)))))) // By Pranay
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArenaInfoCell", for: indexPath) as! ArenaInfoCell
        cell.index = indexPath.item
        cell.infoType = infoType
        cell.tvData.reloadData()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: cvInfo.frame.width, height: cvInfo.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        currentPage = pageControl!.currentPage
        setTitle()
    }
}

