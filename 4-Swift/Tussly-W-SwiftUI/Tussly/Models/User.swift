//
//  User.swift
//  - Describes User & related information

//  Tussly
//
//  Created by Jaimesh Patel on 15/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//


struct User: Codable {
    var id: Int
    var firstName: String
    var lastName: String
    var displayName: String?
    var slug: String
    var email: String
    var countryCode: String?
    var mobileNo: String
    var userName: String
    var gender: String
    var genderText: String?
    var isPlayerCard: Int
    var playerDescription: String
    var permissions: String?
    var isActive: Int
    var emailVerified: Int
    var mobileVerified: Int
    var avatarImage: String
    var bannerImage: String
    var avatarImageFlag: Int
    var bannerImageFlag: Int
    var otp: String?
    var tempEmailMobileNo: String?
}

struct GamerTag: Codable {
    var id: Int
    var consoleName: String?
    var isSelected: Bool?
    var consoleIcon: String?
    var userId: Int?
    var gameConsoleId: Int?
    var gameTags: String?
    var isPublic: Int?
    var userGamerTags: [UserGameID]?
}

struct UserGameID: Codable {
    var id: Int
    var gameConsoleId: Int?
    var isPublic: Int?
    var gameTags: String?
}

struct UserNotification: Codable {
    var id: Int?
    var notificationType: Int?
    var title: String?
    var description: String?
    var action: String?
    var positiveText: String?
    var negativeText: String?
    var isRead: Int?
    var isActionDone: Int?
    var isLike: Int?
    var senderImage: String?
    var notificationTime: String?
    var isDetailView: Int?
    
    var attachmentUrl: String?
    var moduleId: Int?
}

struct FriendRequest: Codable {
    var userId: Int?
    var displayName: String?
    var avatarImage: String?
    var friendRequestId: Int?
    var notificationId: Int?
    var requestOn: String?
    var status: String?
    var friendStatus: Int?
}
