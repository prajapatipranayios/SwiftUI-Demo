//
//  ChatListTVCell.swift
//  Tussly
//
//  Created by Auxano on 11/04/25.
//  Copyright © 2025 Auxano. All rights reserved.
//

import UIKit

class ChatListTVCell: UITableViewCell {
    
    @IBOutlet weak var viewProfileImg: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var viewMsgDetail: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMsgDateTime: UILabel!
    @IBOutlet weak var lblLastMsg: UILabel!
    @IBOutlet weak var lblUnreadMsgCount: UILabel!
    @IBOutlet weak var lblSeparator: UILabel!
    @IBOutlet weak var viewRecentPhoto: UIView!
    @IBOutlet weak var imgRecentPhoto: UIImageView!
    @IBOutlet weak var lblRecentPhotoVideoFile: UILabel!
    @IBOutlet weak var viewMainBG: UIView!
    @IBOutlet weak var imgUserStatus: UIImageView! {
        didSet {
            self.imgUserStatus.clipsToBounds = true
            self.imgUserStatus.layer.cornerRadius = self.imgUserStatus.frame.width / 2
            self.imgUserStatus.isHidden = true
        }
    }
    
    private var imageRequest: Cancellable?
    var bundle = Bundle()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //bundle = Bundle(for: UserDetailTVCell.self)
        
        lblUnreadMsgCount.clipsToBounds = true
        lblUnreadMsgCount.backgroundColor = Colors.theme.returnColor()
        lblLastMsg.isHidden = true
        viewRecentPhoto.isHidden = true
        
        viewMainBG.layer.cornerRadius = 10
        self.lblSeparator.backgroundColor = .clear
        self.viewProfileImg.backgroundColor = .clear
        self.viewMsgDetail.backgroundColor = .clear
        
    }
    
    func configure(_ name : String,_ groupImage : String,_ msgType : String, isGroup : Bool)
    {
        viewProfileImg.layer.cornerRadius = viewProfileImg.frame.height / 2
        imgProfile.layer.cornerRadius = imgProfile.frame.height / 2
        lblUnreadMsgCount.layer.cornerRadius = lblUnreadMsgCount.frame.height / 2
        lblSeparator.backgroundColor = .lightGray.withAlphaComponent(0.5)
        
        imgProfile.backgroundColor = .clear
        viewProfileImg.backgroundColor = .clear
        viewMsgDetail.backgroundColor = .clear
        
        lblUserName.text = name
        
        if msgType == ""
        {
            lblLastMsg.isHidden = false
        }
        else if msgType == "text"
        {
            lblLastMsg.isHidden = false
        }
        
        self.imgProfile.setImage(imageUrl: groupImage)
        
        self.lblUserName.textColor = Colors.black.returnColor()
        self.lblLastMsg.textColor = Colors.black.returnColor()
        self.lblMsgDateTime.textColor = Colors.black.returnColor()
    }
    
    override func prepareForReuse() {
        lblLastMsg.isHidden = true
        viewRecentPhoto.isHidden = true
        
        // Reset Thumbnail Image View
        imgProfile.image = nil
        
        // Cancel Image Request
        imageRequest?.cancel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}



import UIKit

class ConversationCell: UITableViewCell {
    
    let avatarImageView = UIImageView()
    let nameLabel = UILabel()
    let lastMessageLabel = UILabel()
    let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func setupUI() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill

        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        lastMessageLabel.font = UIFont.systemFont(ofSize: 14)
        lastMessageLabel.textColor = .gray
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .gray
        timeLabel.textAlignment = .right

        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -10),

            lastMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            lastMessageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            lastMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            lastMessageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            timeLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

    func configure(name: String, avatarUrl: String, lastMessage: String, time: String) {
        nameLabel.text = name
        lastMessageLabel.text = lastMessage
        timeLabel.text = time
        
        if let url = URL(string: avatarUrl) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.avatarImageView.image = UIImage(data: data)
                    }
                }
            }
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle")
        }
    }
}
