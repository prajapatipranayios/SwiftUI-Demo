//
//  EventFoodItemCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 03/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class EventFoodItemCell: UITableViewCell {

    @IBOutlet weak var lblFoodName: UILabel!
    @IBOutlet weak var lblFoodQty: UILabel!
    @IBOutlet weak var lblFoodIngr: UILabel!
    @IBOutlet weak var lblFoodTag: UILabel!
    
    @IBOutlet weak var tvCostingSheet: UITableView!
    @IBOutlet weak var heightTVCostingSheet: NSLayoutConstraint!
    
    var costingSheet: [CostingSheet]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        tvCostingSheet.register(UINib(nibName: "CostingSheetCell", bundle: nil), forCellReuseIdentifier: "CostingSheetCell")

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCostingSheet(sheet: [CostingSheet]) {
        costingSheet = sheet
        tvCostingSheet.dataSource = self
        tvCostingSheet.delegate = self
        tvCostingSheet.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.heightTVCostingSheet.constant = CGFloat(((self.costingSheet?.count)! * 50) + 50)
            self.contentView.layoutIfNeeded()
        })
    }
    
}

extension EventFoodItemCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return costingSheet!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCostingSheetCell") as! EventCostingSheetCell
        cell.backgroundColor = indexPath.row % 2 == 1 ? UIColor.white : Colors.light.returnColor()
        
        let sheet = costingSheet![indexPath.row]
        
        cell.lblIngr.text = sheet.name
        cell.lblCost.text = "\(sheet.sign ?? "")\(String(format: "%.2f", sheet.price))"

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
