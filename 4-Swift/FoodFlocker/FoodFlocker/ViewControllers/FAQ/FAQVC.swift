//
//  FAQVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 29/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class FAQVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var tvFAQ: UITableView!

    var faqsList = [FAQ]()
    
    var selectedIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tvFAQ.register(UINib(nibName: "FAQSecHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "FAQSecHeaderView")
        tvFAQ.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tvFAQ.rowHeight = UITableView.automaticDimension
        tvFAQ.estimatedRowHeight = 100.0

        tvFAQ.sectionHeaderHeight = UITableView.automaticDimension
        tvFAQ.estimatedSectionHeaderHeight = 60.0

        DispatchQueue.main.async {
            self.setupUI()
        }
        getFAQs()
    }
    
    func setupUI() {
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Webservices

    func getFAQs() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getFAQs()
                }
            }
            return
        }
                        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_FAQs, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            DispatchQueue.main.async {
                if response?.status == 1 {
                    self.faqsList = (response?.result?.faqsList)!
                    if self.faqsList.count > 0 {
                        self.tvFAQ.dataSource = self
                        self.tvFAQ.delegate = self
                        self.tvFAQ.reloadData()
                    }
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }

}

extension FAQVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return faqsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedIndex == section ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FAQSecHeaderView") as! FAQSecHeaderView
        
        header.lblQue.text = faqsList[section].question
        header.ivExpand.image = UIImage(named: selectedIndex == section ? "Minus" : "PlusExp")
        header.viewSep.isHidden = selectedIndex == section
        header.btnExp.tag = section
        header.btnExp.addTarget(self, action: #selector(btnExpTapped(_:)), for: .touchUpInside)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.selectionStyle = .none
        cell.textLabel?.font = Fonts.Regular.returnFont(size: 14.0)
        cell.textLabel?.text = faqsList[indexPath.section].answer
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = UIColor.white
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    @objc func btnExpTapped(_ sender: UIButton) {
        if selectedIndex == sender.tag {
            selectedIndex = -1
        }else {
            selectedIndex = sender.tag
        }
        
        tvFAQ.reloadData()
    }
}
