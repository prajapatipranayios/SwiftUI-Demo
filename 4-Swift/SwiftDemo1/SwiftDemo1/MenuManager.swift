//
//  MenuManager.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/03/25.
//

import Foundation
import UIKit

class SideMenuManager {
    static let shared = SideMenuManager()
    private var sideMenuViewController: SideMenuViewController!
    private var isMenuShown = false
    
    func setup() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sideMenuViewController = storyboard.instantiateViewController(withIdentifier: "SideMenuViewController") as? SideMenuViewController
        
        guard let window = UIApplication.shared.keyWindow else { return }
        sideMenuViewController.view.frame = CGRect(x: -window.frame.width, y: 0, width: window.frame.width * 0.75, height: window.frame.height)
        window.addSubview(sideMenuViewController.view)
    }
    
    func toggleMenu() {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        UIView.animate(withDuration: 0.3) {
            if self.isMenuShown {
                self.sideMenuViewController.view.frame.origin.x = -window.frame.width
            } else {
                self.sideMenuViewController.view.frame.origin.x = 0
            }
            self.isMenuShown.toggle()
        }
    }
    
    func hideMenu() {
        guard let window = UIApplication.shared.keyWindow else { return }
        UIView.animate(withDuration: 0.3) {
            self.sideMenuViewController.view.frame.origin.x = -window.frame.width
            self.isMenuShown = false
        }
    }
}
