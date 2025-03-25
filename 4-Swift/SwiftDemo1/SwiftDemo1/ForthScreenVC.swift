//
//  ForthScreenVC.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/03/25.
//

import UIKit

class ForthScreenVC: UIViewController, SideMenuDelegate {
    
    var sideMenuViewController: SideMenuViewController!
    
    private let menuVC = SidemenuComponent()
    private var isLoggedIn = false // Update based on user status
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        menuVC.delegate = self
        menuVC.updateMenuItems(forUserLoggedIn: isLoggedIn)
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide side menu when coming back to this view
        //ViewController.shared?.sideMenuViewController.view.frame.origin.x = -view.frame.width
    }
    
    @IBAction func btnNextScreen(_ sender: UIButton) {
        //ViewController.shared?.toggleSideMenu()
        menuVC.showMenu(from: self)
    }
    
    private func setupNavigationBar() {
        let menuButton = UIBarButtonItem(title: "☰", style: .plain, target: self, action: #selector(showMenu))
        navigationItem.leftBarButtonItem = menuButton
    }
    
    @objc func showMenu() {
        menuVC.showMenu(from: self)
    }
    
    func didSelectMenuItem(named: String) {
        print("Selected: \(named)")
    }
}
