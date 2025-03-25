//
//  SidemenuComponent.swift
//  SwiftDemo1
//
//  Created by Auxano on 25/03/25.
//

import Foundation
import UIKit

protocol SideMenuDelegate: AnyObject {
    func didSelectMenuItem(named: String)
}

class SidemenuComponent: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: SideMenuDelegate?
    private var menuItems: [String] = []
    private let tableView = UITableView()
    private let menuWidth: CGFloat = 250
    private var isLoggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenu()
    }
    
    func updateMenuItems(forUserLoggedIn isLoggedIn: Bool) {
        self.isLoggedIn = isLoggedIn
        menuItems = isLoggedIn ? ["Dashboard", "Profile", "Settings", "Logout"] : ["Login", "About", "Help"]
        tableView.reloadData()
    }
    
    private func setupMenu() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        tableView.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: view.frame.height)
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        //view.addGestureRecognizer(tapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideMenu(_:)))
        tapGesture.cancelsTouchesInView = false // Allows tableView taps to go through
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTapOutsideMenu(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !tableView.frame.contains(location) {
            dismissMenu()
        }
    }
    
    func showMenu(from parentVC: UIViewController) {
        print("Side menu presented")
//        parentVC.addChild(self)
//        parentVC.view.addSubview(view)
//        self.view.frame = parentVC.view.bounds
        parentVC.addChild(self)
        parentVC.view.addSubview(view)
        self.view.frame = parentVC.view.bounds
        
        UIView.animate(withDuration: 0.3) {
            self.tableView.frame.origin.x = 0
        }
    }
    
    @objc private func dismissMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.frame.origin.x = -self.menuWidth
        }) { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    // TableView DataSource & Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedItem = menuItems[indexPath.row]
//        delegate?.didSelectMenuItem(named: selectedItem)
//        dismissMenu()
        
        let selectedItem = menuItems[indexPath.row]
        print("Menu item selected: \(selectedItem)")
        print("Delegate exists: \(delegate != nil)")
        delegate?.didSelectMenuItem(named: selectedItem)
        dismissMenu()
    }
}

class RootViewController: UIViewController, SideMenuDelegate {
    
    private let menuVC = SidemenuComponent()
    private var isLoggedIn = false // Update based on user status
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuVC.delegate = self
        menuVC.updateMenuItems(forUserLoggedIn: isLoggedIn)
        setupNavigationBar()
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
        switch named {
        case "Dashboard":
            navigationController?.pushViewController(SecondScreenVC(), animated: true)
        case "Profile":
            navigationController?.pushViewController(ThirdScreenVC(), animated: true)
        case "Settings":
            navigationController?.pushViewController(ForthScreenVC(), animated: true)
        case "Logout":
            isLoggedIn = false
            menuVC.updateMenuItems(forUserLoggedIn: isLoggedIn)
        case "Login":
            isLoggedIn = true
            menuVC.updateMenuItems(forUserLoggedIn: isLoggedIn)
            navigationController?.pushViewController(SecondScreenVC(), animated: true)
        case "About":
            navigationController?.pushViewController(ThirdScreenVC(), animated: true)
        case "Help":
            navigationController?.pushViewController(ForthScreenVC(), animated: true)
        default:
            break
        }
    }
}
