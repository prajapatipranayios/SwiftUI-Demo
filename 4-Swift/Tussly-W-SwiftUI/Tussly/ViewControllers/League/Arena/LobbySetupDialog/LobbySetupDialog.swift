//
//  LobbySetupDialog.swift
//  Tussly
//
//  Created by Jaimesh Patel on 19/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class LobbySetupDialog: UIViewController
{
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var cvSteps: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!

    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var arrLoby = [GameLobby]()
    var titleLoby = ""
    
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
        btnClose.layer.cornerRadius = 15.0
        self.pageControl.numberOfPages = arrLoby.count
        
        self.lblTitle.text = titleLoby
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.layoutCells()
        })
    }
    
    // MARK: - UI Methods
    
    func layoutCells()
    {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: cvSteps.frame.width, height: cvSteps.frame.height)
        layout.scrollDirection = .horizontal
        self.cvSteps.setCollectionViewLayout(layout, animated: true)
    }

    // MARK: - Button Click Events
    
    @IBAction func closeTapped(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension LobbySetupDialog: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrLoby.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LobbySetupCVCell", for: indexPath) as! LobbySetupCVCell
        cell.lblStepTitle.text = "Step \(arrLoby[indexPath.item].stepNo ?? 0)"
        cell.lblStep.text = arrLoby[indexPath.item].lobbyContent
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: cvSteps.frame.width, height: cvSteps.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
