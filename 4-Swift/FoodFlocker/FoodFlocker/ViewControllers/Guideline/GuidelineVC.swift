//
//  GuidelineVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 02/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class GuidelineVC: UIViewController {

    //Outlets
    @IBOutlet weak var btnGotIt: UIButton!
    
    var posts = ["Posts",
                "Events",
                "Follow Users",
                "Personal Posts",
                "Chat"]
    
    var messages = ["The user can view, add, update, and delete food posts.",
                    "The user can view, add, update, and delete events.",
                    "The user can follow other users.",
                    "The user can add/delete personal posts.",
                    "The user can chat with others."]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
    }
    
    func setupUI() {
        btnGotIt.layer.cornerRadius = btnGotIt.frame.size.height / 2
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Button Click Events

    @IBAction func gotItTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
    }
}

extension GuidelineVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuidelineTVCell", for: indexPath) as! GuidelineTVCell
        let post = posts[indexPath.row]
        
        cell.ivGuideline.image = UIImage(named: post)
        
        let title = "\(post) : "
        let message = messages[indexPath.row]
        
        let attributedString = NSMutableAttributedString(string: title + message, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0)])
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: (title + message).trimmedString.count))
        attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 16.0), range: NSRange(location: 0, length: title.count))

        cell.lblMessage.attributedText = attributedString
        
        
        
        return cell
    }
}
