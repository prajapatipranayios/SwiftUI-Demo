//
//  Team.swift
//  - Describes Team & related information

//  Tussly
//
//  Created by Auxano on 19/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

struct Team: Codable {
    var id: Int?
    var teamStatus: Int?
    var teamName: String?
    var teamLogo: String?
    var teamBanner: String?
    var displayName: String?
    var teamDescription: String?
    var updatedAt: String?
    var createdAt: String?
    var teamMemberStatus: Int?
    var isRestrictToJoinRequest: Int?
    var logoImage: String?
    var bannerImage: String?
    var firstName: String?
    var lastName: String?
    var avatarImage: String?
    var chatId: String?
    var inviteUrl: String?
}

struct TeamInfo: Codable {
    var standings: Int?
    var leagueId: Int?
    var wl: String?
    var leagueLogo: String?
    var playOffs: String?
    var leagueName: String?
    var date: String?
    var matchWin: Int?
    var stock: String?
    var matchLoss: Int?
    var rwrl: String?
}

struct PlayerInfo: Codable {
    var userId: Int?
    var teamId: Int?
    var stock: String?
    var roundWin: Int?
    var roundLose: Int?
    var firstName: String?
    var lastName: String?
    var matchWin: Int?
    var matchLoss: Int?
    var avatarImage: String?
    var userName: String?
}

struct TeamPlayer: Codable {
    var id: Int?
    var firstName: String?
    var lastName: String?
}
