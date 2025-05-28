 
import UIKit

class AddFoodForEventVC: UIViewController {

    //Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewBottomContainer: UIView!
    @IBOutlet weak var btnAdd: UIButton!
    
    @IBOutlet weak var lblCategoryTitle: UILabel!

    @IBOutlet weak var viewFoodTypeContainer: UIView!
    @IBOutlet var btnFoodTypes: [UIButton]!
    
    @IBOutlet var viewBack: [UIView]!
    @IBOutlet var textFields: [FFTextField]!
    @IBOutlet var lblError : [UILabel]!
    
    @IBOutlet weak var tvCostingSheet: UITableView!
    @IBOutlet weak var heightTVCostingSheet: NSLayoutConstraint!
    
    var selectedFoodType: Int = -1
    
    let imagePicker =  UIImagePickerController()
    
    var addFoodItem: ((Dictionary<String, Any>)->Void)?
    
    var costingSheet = [["name": "", "price": ""],
                        ["name": "", "price": ""]]
    
    var foodDetailsToEdit: Dictionary<String, Any>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async {
            self.setupUI()
            
            if self.foodDetailsToEdit != nil {
                self.lblTitle.text = "Edit Food"
                self.btnAdd.setTitle("Update", for: .normal)
                self.textFields[0].text = self.foodDetailsToEdit!["foodName"] as? String
                self.textFields[1].text = self.foodDetailsToEdit!["quantity"] as? String
                self.textFields[2].text = self.foodDetailsToEdit!["tags"] as? String
                self.textFields[3].text = self.foodDetailsToEdit!["ingredients"] as? String
                
                if let costingSheet = self.foodDetailsToEdit!["costingSheet"] as? Array<Dictionary<String, String>> {
                    self.costingSheet = costingSheet
                    self.tvCostingSheet.reloadData()
                }
                
                if self.foodDetailsToEdit!["categoryId"] as? Int == 1 {
                    self.onTapFoodType(self.btnFoodTypes[0])
                } else {
                    self.onTapFoodType(self.btnFoodTypes[1])
                }

                self.btnAdd.isUserInteractionEnabled = true
                self.btnAdd.backgroundColor = Colors.orange.returnColor()
            }else {
                self.lblTitle.text = "Add Food"
                self.btnAdd.setTitle("Add", for: .normal)
            }
        }
        
        tvCostingSheet.register(UINib(nibName: "AddCostSheetTVCell", bundle: nil), forCellReuseIdentifier: "AddCostSheetTVCell")
        tvCostingSheet.dataSource = self
        tvCostingSheet.delegate = self
        tvCostingSheet.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvCostingSheet.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvCostingSheet.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.heightTVCostingSheet.constant = newsize.height
                self.updateViewConstraints()
            
            }
        }
    }
    
    func setupUI() {
        lblCategoryTitle.setAttributedRequiredText()
        
        textFields[0].setAttributedPlaceholder(Colors.lightGray.returnColor())
        textFields[1].setAttributedPlaceholder(Colors.lightGray.returnColor())
        textFields[2].setAttributedPlaceholder(Colors.lightGray.returnColor())

        textFields[0].addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        textFields[1].addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        textFields[2].addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)


        self.btnAdd.layer.cornerRadius = self.btnAdd.frame.size.height / 2
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.roundCornersWithShadow(corners: [.topLeft,.topRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.addShadow(offset: CGSize(width: 0, height: -5.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
        
        viewFoodTypeContainer.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        viewFoodTypeContainer.layer.borderWidth = 1.0
        viewFoodTypeContainer.layer.cornerRadius = viewFoodTypeContainer.frame.size.height / 2
        
        for btn in btnFoodTypes {
            btn.layer.cornerRadius = btn.frame.size.height / 2
        }
        
        selectedFoodType = 1
        btnFoodTypes[0].isSelected = true
        btnFoodTypes[0].backgroundColor = Colors.themeGreen.returnColor()
        btnFoodTypes[0].setTitleColor(UIColor.white, for: .normal)
        btnFoodTypes[0].titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
        
        
        for view in viewBack {
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = view.frame.size.height / 2
        }
        
        btnAdd.isUserInteractionEnabled = false
        btnAdd.backgroundColor = Colors.inactiveButton.returnColor()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textFields[2] == textField {
            if textFields[2].text!.count > 0 {
                if textFields[2].text?.count == 1 && textFields[2].text != "#" {
                    textFields[2].text = "#\(textFields[2].text ?? "")"
                }else {
                    
                    if textFields[2].text!.last != " " && textFields[2].text!.last != "," && textFields[2].text?.count != 1 {
                        let lastChar = textFields[2].text!.last == nil ? "#" : String(textFields[2].text!).last
                        textFields[2].text! = String(textFields[2].text!.dropLast())
                        
                        if lastChar == "#" {
                            if textFields[2].text!.last == "," {
                                textFields[2].text! += " \(String(lastChar!))"
                            }else if textFields[2].text!.last != " " && textFields[2].text!.last != "," {
                                textFields[2].text! += ", \(String(lastChar!))"
                            }else {
                                textFields[2].text! += "\(String(lastChar!))"
                            }
                        }else {
                            if textFields[2].text!.last == "," {
                                if lastChar != "#" {
                                    textFields[2].text! += " #\(String(lastChar!))"
                                }else {
                                    textFields[2].text! += " \(String(lastChar!))"
                                }
                            }else if textFields[2].text!.last == " " {
                                if lastChar != "#" {
                                    textFields[2].text! += "#\(String(lastChar!))"
                                }
                            }else {
                                textFields[2].text! += "\(String(lastChar!))"
                            }
                        }
                    }else {
                        let lastChar = textFields[2].text!.last == nil ? "#" : String(textFields[2].text!).last
                        textFields[2].text! = String(textFields[2].text!.dropLast())
                        
                        if lastChar == " " {
                            if textFields[2].text!.last != "," {
                                textFields[2].text! += ",\(String(lastChar!))"
                            }else {
                                if textFields[2].text!.last != "," {
                                    textFields[2].text! += ",\(String(lastChar!))"
                                }else {
                                    textFields[2].text! += "\(String(lastChar!))"
                                }
                            }
                        }else if lastChar == "," {
                            if textFields[2].text!.last != " " {
    //                            textFields[2].text! += ",\(String(lastChar!))"
                            }else {
                                textFields[2].text! += "\(String(lastChar!))"
                            }
                        }else {
                            textFields[2].text! += "\(String(lastChar!))"
                        }
                    }
                }
            }
            
        }
        
        var value = true
        
        if textFields[0].text?.trimmedString == "" || textFields[1].text?.trimmedString == "" || textFields[2].text?.trimmedString == "" {
            value = false
        }
            
        if value == true {
            btnAdd.backgroundColor = Colors.orange.returnColor()
            btnAdd.isUserInteractionEnabled = true
        } else {
            btnAdd.isUserInteractionEnabled = false
            btnAdd.backgroundColor = Colors.inactiveButton.returnColor()
        }
    }
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i != 3 {
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    lblError[i].text = ""
                    //
                    viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                    textFields[i].setAttributedTitle(Colors.gray.returnColor())
                    //
                }
            } else {
                if textFields[i].text == "" {
                    viewBack[i].layer.borderColor = Colors.lightGray.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.lightGray.returnColor()
                } else {
                    viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                    textFields[i].setAttributedTitle(Colors.gray.returnColor())
                }
            }
        }
        
        return value
    }

    func checkDiscardValue() -> Bool {
        var value = false
        
        if foodDetailsToEdit != nil {
            if (self.textFields[0].text != self.foodDetailsToEdit!["foodName"] as? String) || (self.textFields[1].text != self.foodDetailsToEdit!["quantity"] as? String) || (selectedFoodType != self.foodDetailsToEdit!["categoryId"] as? Int) || (self.textFields[2].text != self.foodDetailsToEdit!["tags"] as? String) || (self.textFields[3].text != self.foodDetailsToEdit!["ingredients"] as? String) {
                value = true
            }
            
            if (self.foodDetailsToEdit!["costingSheet"] as? [[String: Any]])!.count == self.costingSheet.count {
                for i in 0..<(self.foodDetailsToEdit!["costingSheet"] as? [[String: Any]])!.count {
                    
                    if ((self.foodDetailsToEdit!["costingSheet"] as? [[String: Any]])![i]["name"] as! String != (self.costingSheet[i]["name"]!)) || ((self.foodDetailsToEdit!["costingSheet"] as? [[String: Any]])![i]["price"]! as! String != (self.costingSheet[i]["price"]! )) {
                        value = true
                        break
                    }
                }
            }
            
        }else {
            if (self.textFields[0].text != "") || (self.textFields[1].text != "") || (selectedFoodType != 1) || (self.textFields[2].text != "") || (self.textFields[3].text != "") {
                value = true
            }
            
            for i in 0..<self.costingSheet.count {
                
                if ((self.costingSheet[i]["name"]!) != "") || ((self.costingSheet[i]["price"]!) != "") {
                    value = true
                    break
                }
            }
        }
        
        
        return value
    }
    
    // MARK: - Button Click Events
    @IBAction func onTapBack(_ sender: UIButton) {
        if checkDiscardValue() {
            let confirmPopup = self.storyboard?.instantiateViewController(withIdentifier: "CancelTicketPopupVC") as! CancelTicketPopupVC
            confirmPopup.titleString = "Are you sure to discard the changes?"
            confirmPopup.yesString = "Yes"
            confirmPopup.noString = "No"
            confirmPopup.tapYes = {
                self.navigationController?.popViewController(animated: true)
            }
            confirmPopup.tapNo = {
                
            }
            confirmPopup.modalPresentationStyle = .overCurrentContext
            confirmPopup.modalTransitionStyle = .crossDissolve
            
            self.present(confirmPopup, animated: true, completion: nil)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onTapFoodType(_ sender: UIButton) {
        selectedFoodType = sender.tag + 1
        for btn in btnFoodTypes {
            if btn.tag == sender.tag {
                btn.backgroundColor = Colors.themeGreen.returnColor()
                btn.setTitleColor(UIColor.white, for: .normal)
                btn.titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
                btn.isSelected = true
            } else {
                btn.backgroundColor = UIColor.clear
                btn.setTitleColor(Colors.lightGray.returnColor() , for: .normal)
                btn.titleLabel?.font = Fonts.Regular.returnFont(size: 14.0)
                btn.isSelected = false
            }
        }
    }
    
    @IBAction func addMoreTapped(_ sender: UIButton) {
        costingSheet.append(["name": "", "price": ""])
        tvCostingSheet.reloadData()
    }
    
    @IBAction func onTapAdd(_ sender: UIButton) {
        view.endEditing(true)
        let valid = checkValidation(to: 0, from: 2)
        
        if valid {
            
            //Add Food to Event and redirect back to Add Event Screen
            var dictFood = ["categoryId": selectedFoodType,
                            "foodName": textFields[0].text!,
                            "quantity": textFields[1].text!,
                            "tags": textFields[2].text!,
                            "ingredients": textFields[3].text!] as [String : Any]
            
            var dictCostingSheet = Array<Dictionary<String, Any>>()
            for i in 0..<costingSheet.count {
                if costingSheet[i]["name"] as! String != "" {
                    dictCostingSheet.append(costingSheet[i])
                }
            }
            dictFood.updateValue(dictCostingSheet, forKey: "costingSheet")
            
            if addFoodItem != nil {
                addFoodItem!(dictFood)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
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

extension AddFoodForEventVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return costingSheet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddCostSheetTVCell") as! AddCostSheetTVCell
        
        cell.textFields[0].text = "\(costingSheet[indexPath.row]["name"]!)"
        cell.textFields[1].text = "\(costingSheet[indexPath.row]["price"]!)"
        
        cell.updateCostingSheet = { tfText, tfTag in
            var dict = self.costingSheet[indexPath.row]
            dict.updateValue(tfText, forKey: tfTag == 0 ? "name" : "price")
            self.costingSheet[indexPath.row] = dict
        }
        return cell
    }
    
}

extension AddFoodForEventVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        viewBack[textField.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor
        textFields[textField.tag].setAttributedTitle(Colors.themeGreen.returnColor())

        if textField.tag == 0 {
            lblError[0].text = ""
        } else if textField.tag == 1 {
            lblError[1].text = ""
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField.tag == 2 {
            if string == "#" {
                let arrValue = textFields[2].text!.split(separator: "#")
                
                if arrValue.count > 6 {
                    return false
                }
            }
        }
        
        if textField.tag == 1 {
            return newString.length <= MAX_QUANTITY_LENGTH
        }else if textField.tag == 3 || textField.tag == 2 {
            return newString.length <= INGREDIANT_LIMIT
        }else {
            return newString.length <= TEXTFIELD_LIMIT
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmedString
        if self.checkValidation(to: textField.tag, from: textField.tag+1) {
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        switch textField.tag {
            case 0,1,2:
                textFields[textField.tag + 1].becomeFirstResponder()
                break
            default:
                view.endEditing(true)
                break
        }
        return true
    }
}
