//
//  SelectAddressVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 13/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class SelectAddressVC: UIViewController {

    fileprivate var dataTask: URLSessionDataTask?
    var arrAddresses = [GoogleAddress]()
    
    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewTFBack: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var tvAddresses: UITableView!

    var getSelectedAddress: ((GoogleAddress)->Void)?
    var mapTasks = MapTasks()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.endEditing(true)
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        tvAddresses.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tvAddresses.dataSource = self
        tvAddresses.delegate = self
        tvAddresses.reloadData()
        
    }
    
    func setupUI() {
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        
        viewTFBack.layer.borderColor = UIColor.lightGray.cgColor
        viewTFBack.layer.borderWidth = 1.0
        viewTFBack.layer.cornerRadius = viewTFBack.frame.size.height / 2
        
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tfSearch.frame.size.height - 10, height: tfSearch.frame.size.height))

        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: mainView.frame.width, height: mainView.frame.height))
        btn.clipsToBounds = true

        btn.setImage(UIImage(named: "Remove"), for: .normal)
        btn.addTarget(self, action: #selector(closeTFTapped), for: .touchUpInside)
        mainView.addSubview(btn)

        tfSearch.rightViewMode = .whileEditing
        tfSearch.rightView = mainView
        
    }
    
    @objc func closeTFTapped() {
        tfSearch.text = ""
        arrAddresses.removeAll()
        tvAddresses.reloadData()
    }

    // MARK: - Button Click Events
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelectAddressVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAddresses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTVCell", for: indexPath) as! AddressTVCell
        cell.lblAddress.text = arrAddresses[indexPath.row].drop_location
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mapTasks.geocodeAddress(self.arrAddresses[indexPath.row].drop_location, withCompletionHandler: { (status, success) -> Void in
            if !success {
                if status == "ZERO_RESULTS" {
                    Utilities.showPopup(title: "The location could not be found.", type: .error)
                }
            }else {
                self.dismiss(animated: true) {
                    if self.getSelectedAddress != nil {
                        self.getSelectedAddress!(GoogleAddress(type: "google", drop_title: self.arrAddresses[indexPath.row].drop_title, drop_location: self.arrAddresses[indexPath.row].drop_location, drop_latitude: self.mapTasks.fetchedAddressLatitude, drop_longitude: self.mapTasks.fetchedAddressLongitude))
                    }
                }
            }
        })
        
    }

}

extension SelectAddressVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if newString != "" {
            self.fetchAutocompletePlaces(newString as String)
        } else {
            arrAddresses.removeAll()
            tvAddresses.reloadData()
        }
//        else {
//            getFilterArray(string: newString as String)
//        }
        return true
    }
}

extension SelectAddressVC {
        
    // Google Auto Complete Places
    fileprivate func fetchAutocompletePlaces(_ keyword: String) {
        let urlString = "\(GOOGLE_AUTO_FILTER_BASE_URL)?key=\(AppInfo.GOOGLE_MAP_API_KEY.returnAppInfo())&input=\(keyword)&sensor=true"
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = URL(string: encodedString) { //encodedString
                
                let request = URLRequest(url: url)
                dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data {
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                            if let status = result["status"] as? String {
                                if status == "OK" {
                                    if let predictions = result["predictions"] as? NSArray {
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            self.arrAddresses.removeAll()
                                            for dict in predictions as! [NSDictionary] {
                                                self.arrAddresses.append(GoogleAddress(type: "google",drop_title: (dict["structured_formatting"] as! [String: Any])["main_text"] as! String, drop_location: dict["description"] as! String, drop_latitude: 0.0, drop_longitude: 0.0))
                                            }
                                            self.tvAddresses.reloadData()
                                            return
                                        })
                                    }
                                }else {
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        self.arrAddresses.removeAll()
                                        self.tvAddresses.reloadData()
                                    })
                                }
                            }
                        }
                        catch let error as NSError {
                            print("Error: \(error.localizedDescription)")
                        }
                    } else {
                        print("Error: \(error!.localizedDescription)")
                    }
                })
                dataTask?.resume()
            }
        }
    }
}
