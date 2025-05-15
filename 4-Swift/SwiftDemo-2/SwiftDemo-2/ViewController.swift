//
//  ViewController.swift
//  SwiftDemo-2
//
//  Created by Auxano on 15/05/25.
//

import UIKit


// Model for our table items
struct DemoItem {
    let title: String
    let imageName: String?
    let viewControllerType: UIViewController.Type
}

class ViewController: UIViewController {
    
    // Your array of strings
    //    let demoItems = [
    //        (title: "Video Demo", imageName: "video"),
    //        (title: "Collection Demo", imageName: "collection"),
    //        (title: "Audio Demo", imageName: "audio"),
    //        (title: "Video With PIP", imageName: nil) // This one won't have an image
    //    ]
    
    let demoItems: [DemoItem] = [
        DemoItem(title: "Video Demo",
                 imageName: "video",
                 viewControllerType: VideoDemoVC.self),
        
        DemoItem(title: "Collection Demo",
                 imageName: "rectangle.grid.2x2",
                 viewControllerType: CollectionDemoVC.self),
        
        DemoItem(title: "Audio Demo",
                 imageName: "music.note",
                 viewControllerType: AudioDemoVC.self),
        
        DemoItem(title: "Video With PIP",
                 imageName: "pip",
                 viewControllerType: VideoPIPVC.self)
    ]
    
    
    // Create a UITableView
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Setup the table view
        setupTableView()
    }
    
    func setupTableView() {
        //        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //        tableView.dataSource = self
        //        tableView.delegate = self
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //        let item = demoItems[indexPath.row]
        //
        //        // Configure cell content
        //        cell.textLabel?.text = item.title
        //
        //        // Set image if available (use system images or your own assets)
        //        if let imageName = item.imageName {
        //            cell.imageView?.image = UIImage(systemName: imageName) ?? UIImage(named: imageName)
        //        } else {
        //            cell.imageView?.image = nil
        //        }
        //
        //        // Add disclosure indicator (arrow on the right)
        //        cell.accessoryType = .disclosureIndicator
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as! CustomTableViewCell
        let item = demoItems[indexPath.row]
        cell.configure(with: item.title, imageName: item.imageName)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected: \(demoItems[indexPath.row].title)")
        if indexPath.row != 0 {
            // Here you would typically navigate to another view controller
            let item = demoItems[indexPath.row]
            let vc = item.viewControllerType.init()
            vc.title = item.title
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let item = demoItems[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoDemoVC") as! VideoDemoVC
            
            vc.title = item.title
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// 1. Define custom cell class
class CustomTableViewCell: UITableViewCell {
    static let identifier = "CustomTableViewCell"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with title: String, imageName: String?) {
        titleLabel.text = title
        
        if let imageName = imageName {
            iconImageView.image = UIImage(systemName: imageName) ?? UIImage(named: imageName)
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
        
        // Add disclosure indicator
        accessoryType = .disclosureIndicator
    }
}
