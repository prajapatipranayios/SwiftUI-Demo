//
//  LeagueInfoVC.swift
//  Tussly
//

import UIKit

class LeagueInfoScheduleVC: UIViewController {
    
    // MARK: - Controls

//    @IBOutlet weak var lblOnlineLan: UILabel!
    @IBOutlet weak var tvSchedule : UITableView!

    
    // MARK: - Variables
    var arrSchedule = [LeagueSchedule]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        arrSchedule.append(LeagueSchedule(id: 0, day: "Monday", time: "8:00 - 10:00 PM ETC"))
        arrSchedule.append(LeagueSchedule(id: 0, day: "Thuesday", time: "8:00 - 10:00 PM ETC"))
        arrSchedule.append(LeagueSchedule(id: 0, day: "Wednesday", time: "8:00 - 10:00 PM ETC"))
        arrSchedule.append(LeagueSchedule(id: 0, day: "Thursday", time: "8:00 - 10:00 PM ETC"))
        arrSchedule.append(LeagueSchedule(id: 0, day: "Friday", time: "8:00 - 10:00 PM ETC"))
        arrSchedule.append(LeagueSchedule(id: 0, day: "Saturday", time: "8:00 - 10:00 PM ETC"))
        arrSchedule.append(LeagueSchedule(id: 0, day: "Sunday", time: "8:00 - 10:00 PM ETC"))

        
        tvSchedule.register(UINib(nibName: "LeagueScheduleCell", bundle: nil), forCellReuseIdentifier: "LeagueScheduleCell")
        tvSchedule.rowHeight = UITableView.automaticDimension
        tvSchedule.estimatedRowHeight = 100.0
        tvSchedule.reloadData()
    }
    
    // MARK: - UI Methods
    
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)

    }
}


// MARK: - UITableViewDelegate

extension LeagueInfoScheduleVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSchedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeagueScheduleCell", for: indexPath) as! LeagueScheduleCell
        
        cell.lblDay.text = arrSchedule[indexPath.row].day
        cell.lblTime.text = arrSchedule[indexPath.row].time
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
