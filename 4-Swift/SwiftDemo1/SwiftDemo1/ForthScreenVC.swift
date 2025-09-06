//
//  ForthScreenVC.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/03/25.
//

import UIKit
import SwiftUI

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
    
    @IBAction func btnConnectAI(_ sender: UIButton) {
        print("AI Button tap event")
        
        let swiftUIView = ConversationalAIView(agent: ObjAgent(), userId: "212", baseUrl: "https://api.openai.com/v1/")
        let hostingController = UIHostingController(rootView: swiftUIView)
        self.navigationController?.pushViewController(hostingController, animated: true)
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
    
    // MARK: - Func Calculate sum of numbers
    func calculateSum(numbers: [Int]) -> Int {
        return numbers.reduce(0, +)
    }
}
